import 'package:get/get.dart';

import '../board/board_controller.dart';
import '../check_in/check_in_controller.dart';
import '../triggers/triggers_controller.dart';
import '../../models/mood_record.dart';
import '../../services/local_storage_service.dart';

class HistoryController extends GetxController {
  HistoryController(this._storage);

  final LocalStorageService _storage;
  final records = <MoodRecord>[].obs;
  final selectedFilter = 'Week'.obs;
  final isLoading = false.obs;

  static const filters = ['Week', 'Month', 'All'];

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<void> loadRecords() async {
    isLoading.value = true;
    records.assignAll(await _storage.loadAllRecords());
    isLoading.value = false;
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<MoodRecord> get visibleRecords {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    final start = switch (selectedFilter.value) {
      'Week' => end.subtract(const Duration(days: 6)),
      'Month' => end.subtract(const Duration(days: 29)),
      'All' => null,
      _ => end.subtract(const Duration(days: 6)),
    };

    final filtered = records.where((record) {
      if (start == null) {
        return true;
      }
      final date = DateTime.tryParse(record.dateKey);
      if (date == null) {
        return false;
      }
      final normalized = DateTime(date.year, date.month, date.day);
      return !normalized.isBefore(start) && !normalized.isAfter(end);
    });

    return filtered.toList()
      ..sort((left, right) => right.dateKey.compareTo(left.dateKey));
  }

  Future<void> saveRecord(MoodRecord record) async {
    await _storage.saveTodayRecord(record);
    final index = records.indexWhere((item) => item.dateKey == record.dateKey);
    if (index == -1) {
      records.add(record);
    } else {
      records[index] = record;
      records.refresh();
    }
    await _refreshRelatedControllers(record.dateKey);
  }

  Future<void> deleteRecord(String dateKey) async {
    await _storage.deleteRecord(dateKey);
    records.removeWhere((record) => record.dateKey == dateKey);
    await _refreshRelatedControllers(dateKey);
  }

  Future<void> _refreshRelatedControllers(String dateKey) async {
    if (Get.isRegistered<BoardController>()) {
      await Get.find<BoardController>().loadBoard();
    }
    if (Get.isRegistered<TriggersController>()) {
      await Get.find<TriggersController>().loadTriggers();
    }
    if (dateKey == MoodRecord.dateKeyFor(DateTime.now()) &&
        Get.isRegistered<CheckInController>()) {
      await Get.find<CheckInController>().loadTodayRecord();
    }
  }
}
