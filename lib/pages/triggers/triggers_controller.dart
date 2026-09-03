import 'package:get/get.dart';

import '../../models/custom_trigger.dart';
import '../../models/mood_record.dart';
import '../../services/local_storage_service.dart';

class TriggerCount {
  const TriggerCount({required this.name, required this.count});

  final String name;
  final int count;
}

class TriggersController extends GetxController {
  TriggersController(this._storage);

  final LocalStorageService _storage;
  final recentRecords = <MoodRecord>[].obs;
  final allRecords = <MoodRecord>[].obs;
  final customTriggers = <CustomTrigger>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTriggers();
  }

  Future<void> loadTriggers() async {
    isLoading.value = true;
    final results = await Future.wait([
      _storage.loadRecentRecords(),
      _storage.loadAllRecords(),
      _storage.loadCustomTriggers(),
    ]);
    recentRecords.assignAll(results[0] as List<MoodRecord>);
    allRecords.assignAll(results[1] as List<MoodRecord>);
    customTriggers.assignAll(results[2] as List<CustomTrigger>);
    isLoading.value = false;
  }

  List<TriggerCount> get topTriggers {
    return _rankedTriggers(recentRecords).take(5).toList();
  }

  List<TriggerCount> get lowMoodTriggers {
    return _rankedTriggers(
      recentRecords.where((record) => record.moodIndex >= 3),
    ).take(5).toList();
  }

  List<TriggerCount> get goodMoodTriggers {
    return _rankedTriggers(
      recentRecords.where((record) => record.moodIndex <= 1),
    ).take(5).toList();
  }

  String? validateName(String value, {String? excludingId}) {
    final name = value.trim();
    if (name.isEmpty) {
      return 'Enter a trigger name.';
    }
    if (name.length > 24) {
      return 'Use 24 characters or fewer.';
    }

    final normalized = name.toLowerCase();
    final duplicateDefault = TriggerDefaults.names.any(
      (item) => item.toLowerCase() == normalized,
    );
    final duplicateCustom = customTriggers.any(
      (item) => item.id != excludingId && item.name.toLowerCase() == normalized,
    );
    if (duplicateDefault || duplicateCustom) {
      return 'That trigger already exists.';
    }
    return null;
  }

  Future<void> addTrigger(String value) async {
    final updated = [
      ...customTriggers,
      CustomTrigger(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: value.trim(),
      ),
    ];
    await _saveCustomTriggers(updated);
  }

  Future<void> editTrigger(CustomTrigger trigger, String value) async {
    final updated = customTriggers
        .map((item) => item.id == trigger.id ? item.rename(value.trim()) : item)
        .toList();
    await _saveCustomTriggers(updated);
  }

  Future<void> deleteTrigger(CustomTrigger trigger) async {
    final updated = customTriggers
        .where((item) => item.id != trigger.id)
        .toList();
    await _saveCustomTriggers(updated);
  }

  int usageCount(CustomTrigger trigger) {
    final names = trigger.allNames.map((item) => item.toLowerCase()).toSet();
    var count = 0;
    for (final record in allRecords) {
      for (final recordTrigger in record.triggers) {
        if (names.contains(recordTrigger.toLowerCase())) {
          count++;
        }
      }
    }
    return count;
  }

  Future<void> _saveCustomTriggers(List<CustomTrigger> updated) async {
    await _storage.saveCustomTriggers(updated);
    customTriggers.assignAll(updated);
  }

  List<TriggerCount> _rankedTriggers(Iterable<MoodRecord> records) {
    final counts = <String, int>{};
    for (final record in records) {
      for (final trigger in record.triggers) {
        counts[trigger] = (counts[trigger] ?? 0) + 1;
      }
    }

    final ranked =
        counts.entries
            .map((entry) => TriggerCount(name: entry.key, count: entry.value))
            .toList()
          ..sort((left, right) {
            final countOrder = right.count.compareTo(left.count);
            if (countOrder != 0) {
              return countOrder;
            }
            return left.name.toLowerCase().compareTo(right.name.toLowerCase());
          });
    return ranked;
  }
}
