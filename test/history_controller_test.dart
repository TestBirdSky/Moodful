import 'package:flutter_test/flutter_test.dart';

import 'package:recordmood/models/mood_record.dart';
import 'package:recordmood/pages/history/history_controller.dart';
import 'package:recordmood/services/local_storage_service.dart';

MoodRecord _record(DateTime date) {
  return MoodRecord(
    dateKey: MoodRecord.dateKeyFor(date),
    moodIndex: 2,
    energy: 'Normal',
    triggers: const ['Sleep'],
    context: '',
  );
}

void main() {
  test('history filters records by week, month, and all time', () {
    final today = DateTime.now();
    final controller = HistoryController(LocalStorageService.inMemory());
    controller.records.addAll([
      _record(today),
      _record(today.subtract(const Duration(days: 6))),
      _record(today.subtract(const Duration(days: 7))),
      _record(today.subtract(const Duration(days: 29))),
      _record(today.subtract(const Duration(days: 30))),
    ]);

    expect(controller.visibleRecords, hasLength(2));

    controller.selectFilter('Month');
    expect(controller.visibleRecords, hasLength(4));

    controller.selectFilter('All');
    expect(controller.visibleRecords, hasLength(5));
  });
}
