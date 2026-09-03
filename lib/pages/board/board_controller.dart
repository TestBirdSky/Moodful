import 'package:get/get.dart';

import '../../models/mood_record.dart';
import '../../services/local_storage_service.dart';

class BoardController extends GetxController {
  BoardController(this._storage);

  final LocalStorageService _storage;
  final recentRecords = <MoodRecord>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBoard();
  }

  Future<void> loadBoard() async {
    isLoading.value = true;
    recentRecords.assignAll(await _storage.loadRecentRecords());
    isLoading.value = false;
  }

  MoodRecord? recordFor(DateTime date) {
    final dateKey = MoodRecord.dateKeyFor(date);
    for (final record in recentRecords) {
      if (record.dateKey == dateKey) {
        return record;
      }
    }
    return null;
  }

  double? get averageMood {
    if (recentRecords.isEmpty) {
      return null;
    }
    final total = recentRecords.fold<int>(
      0,
      (sum, record) => sum + moodScore(record.moodIndex),
    );
    return total / recentRecords.length;
  }

  int get lowDays {
    return recentRecords.where((record) => record.moodIndex >= 3).length;
  }

  String? get topTrigger {
    final counts = <String, int>{};
    for (final record in recentRecords) {
      for (final trigger in record.triggers) {
        counts[trigger] = (counts[trigger] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) {
      return null;
    }

    return counts.entries.reduce((current, next) {
      return next.value > current.value ? next : current;
    }).key;
  }

  int moodScore(int moodIndex) {
    return 5 - moodIndex.clamp(0, 4);
  }

  int moodIndexForAverage(double average) {
    return (5 - average).round().clamp(0, 4);
  }

  int? get moodDifference {
    final today = recordFor(DateTime.now());
    final yesterday = recordFor(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    if (today == null || yesterday == null) {
      return null;
    }
    return moodScore(today.moodIndex) - moodScore(yesterday.moodIndex);
  }

  String? get latestContext {
    for (final record in recentRecords.reversed) {
      if (record.context.trim().isNotEmpty) {
        return record.context.trim();
      }
    }
    return null;
  }
}
