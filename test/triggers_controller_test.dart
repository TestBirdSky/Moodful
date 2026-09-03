import 'package:flutter_test/flutter_test.dart';

import 'package:recordmood/models/custom_trigger.dart';
import 'package:recordmood/models/mood_record.dart';
import 'package:recordmood/pages/triggers/triggers_controller.dart';
import 'package:recordmood/services/local_storage_service.dart';

void main() {
  test(
    'builds weekly trigger insights and preserves historical names',
    () async {
      final today = DateTime.now();
      final records = [
        MoodRecord(
          dateKey: MoodRecord.dateKeyFor(today),
          moodIndex: 3,
          energy: 'Low',
          triggers: const ['Sleep', 'Friends'],
          context: '',
        ),
        MoodRecord(
          dateKey: MoodRecord.dateKeyFor(
            today.subtract(const Duration(days: 1)),
          ),
          moodIndex: 0,
          energy: 'High',
          triggers: const ['Sleep', 'Work'],
          context: '',
        ),
        MoodRecord(
          dateKey: MoodRecord.dateKeyFor(
            today.subtract(const Duration(days: 2)),
          ),
          moodIndex: 4,
          energy: 'Low',
          triggers: const ['Weather'],
          context: '',
        ),
      ];
      final storage = LocalStorageService.inMemory(
        records: records,
        customTriggers: const [CustomTrigger(id: 'friends', name: 'Friends')],
      );
      final controller = TriggersController(storage);

      await controller.loadTriggers();

      expect(
        controller.topTriggers
            .map((trigger) => (trigger.name, trigger.count))
            .toList(),
        [('Sleep', 2), ('Friends', 1), ('Weather', 1), ('Work', 1)],
      );
      expect(controller.lowMoodTriggers.map((trigger) => trigger.name), [
        'Friends',
        'Sleep',
        'Weather',
      ]);
      expect(controller.goodMoodTriggers.map((trigger) => trigger.name), [
        'Sleep',
        'Work',
      ]);

      final friends = controller.customTriggers.single;
      await controller.editTrigger(friends, 'Social');

      expect(controller.customTriggers.single.name, 'Social');
      expect(controller.customTriggers.single.previousNames, ['Friends']);
      expect(controller.usageCount(controller.customTriggers.single), 1);
      expect(
        (await storage.loadAllRecords()).map((record) => record.toJson()),
        (records.toList()
              ..sort((left, right) => left.dateKey.compareTo(right.dateKey)))
            .map((record) => record.toJson()),
      );

      await controller.deleteTrigger(controller.customTriggers.single);

      expect(controller.customTriggers, isEmpty);
      expect(
        (await storage.loadAllRecords()).map((record) => record.toJson()),
        (records.toList()
              ..sort((left, right) => left.dateKey.compareTo(right.dateKey)))
            .map((record) => record.toJson()),
      );
    },
  );
}
