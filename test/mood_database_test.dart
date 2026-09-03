import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:recordmood/models/custom_trigger.dart';
import 'package:recordmood/models/mood_record.dart';
import 'package:recordmood/services/mood_database.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('SQLite stores, updates, queries, and deletes mood data', () async {
    final database = await SqfliteMoodDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(database.close);

    await database.upsertRecord(
      const MoodRecord(
        dateKey: '2026-09-02',
        moodIndex: 3,
        energy: 'Low',
        triggers: ['Sleep', 'Work'],
        context: 'First version.',
      ),
    );
    await database.upsertRecord(
      const MoodRecord(
        dateKey: '2026-09-03',
        moodIndex: 1,
        energy: 'High',
        triggers: ['Friends'],
        context: 'A better day.',
      ),
    );

    await database.upsertRecord(
      const MoodRecord(
        dateKey: '2026-09-02',
        moodIndex: 2,
        energy: 'Normal',
        triggers: ['Weather'],
        context: 'Updated version.',
      ),
    );

    final updated = await database.loadRecord('2026-09-02');
    expect(updated?.moodIndex, 2);
    expect(updated?.energy, 'Normal');
    expect(updated?.triggers, ['Weather']);
    expect(updated?.context, 'Updated version.');

    final range = await database.loadRecords(
      startDateKey: '2026-09-03',
      endDateKey: '2026-09-03',
    );
    expect(range, hasLength(1));
    expect(range.single.dateKey, '2026-09-03');

    await database.replaceCustomTriggers([
      const CustomTrigger(id: 'friends', name: 'Friends'),
      const CustomTrigger(
        id: 'walk',
        name: 'Walk',
        previousNames: ['Exercise'],
      ),
    ]);
    final customTriggers = await database.loadCustomTriggers();
    expect(customTriggers.map((trigger) => trigger.name), ['Friends', 'Walk']);
    expect(customTriggers.last.previousNames, ['Exercise']);

    await database.deleteRecord('2026-09-02');
    expect(await database.loadRecord('2026-09-02'), isNull);
    expect(await database.loadRecords(), hasLength(1));
  });
}
