import 'package:flutter_test/flutter_test.dart';

import 'package:recordmood/models/mood_record.dart';
import 'package:recordmood/pages/check_in/check_in_controller.dart';
import 'package:recordmood/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new day resets the check-in form', () async {
    var now = DateTime(2026, 9, 2, 23, 59);
    final storage = LocalStorageService.inMemory();
    await storage.saveTodayRecord(
      MoodRecord(
        dateKey: MoodRecord.dateKeyFor(now),
        moodIndex: 4,
        energy: 'Low',
        triggers: const ['Sleep', 'Work'],
        context: 'A difficult afternoon.',
      ),
    );
    final controller = CheckInController(storage, now: () => now);
    addTearDown(controller.onClose);

    await controller.loadTodayRecord();
    expect(controller.hasTodayRecord.value, isTrue);
    expect(controller.selectedMoodIndex.value, 4);
    expect(controller.selectedEnergy.value, 'Low');
    expect(controller.selectedTriggers, {'Sleep', 'Work'});
    expect(controller.contextController.text, 'A difficult afternoon.');

    now = DateTime(2026, 9, 3);
    await controller.refreshForCurrentDay();

    expect(controller.hasTodayRecord.value, isFalse);
    expect(controller.selectedMoodIndex.value, 2);
    expect(controller.selectedEnergy.value, 'High');
    expect(controller.selectedTriggers, isEmpty);
    expect(controller.contextController.text, isEmpty);
  });
}
