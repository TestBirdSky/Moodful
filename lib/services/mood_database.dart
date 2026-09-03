import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/custom_trigger.dart';
import '../models/mood_record.dart';

abstract interface class MoodDatabase {
  Future<MoodRecord?> loadRecord(String dateKey);

  Future<List<MoodRecord>> loadRecords({
    String? startDateKey,
    String? endDateKey,
  });

  Future<void> upsertRecord(MoodRecord record);

  Future<void> deleteRecord(String dateKey);

  Future<List<CustomTrigger>> loadCustomTriggers();

  Future<void> replaceCustomTriggers(List<CustomTrigger> triggers);

  Future<void> close();
}

class SqfliteMoodDatabase implements MoodDatabase {
  SqfliteMoodDatabase._(this._database);

  static const _databaseName = 'record_mood.db';
  static const _databaseVersion = 1;
  static const _recordsTable = 'mood_records';
  static const _recordTriggersTable = 'record_triggers';
  static const _customTriggersTable = 'custom_triggers';

  final Database _database;

  static Future<SqfliteMoodDatabase> open({
    DatabaseFactory? factory,
    String path = _databaseName,
  }) async {
    final database = await (factory ?? databaseFactory).openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) async {
          await database.execute('''
          CREATE TABLE $_recordsTable (
            date_key TEXT PRIMARY KEY,
            mood_index INTEGER NOT NULL,
            energy TEXT,
            context TEXT NOT NULL DEFAULT '',
            updated_at INTEGER NOT NULL
          )
        ''');
          await database.execute('''
          CREATE TABLE $_recordTriggersTable (
            record_date_key TEXT NOT NULL,
            trigger_name TEXT NOT NULL,
            position INTEGER NOT NULL,
            PRIMARY KEY (record_date_key, trigger_name),
            FOREIGN KEY (record_date_key)
              REFERENCES $_recordsTable(date_key)
              ON DELETE CASCADE
          )
        ''');
          await database.execute('''
          CREATE INDEX record_triggers_date_index
          ON $_recordTriggersTable(record_date_key)
        ''');
          await database.execute('''
          CREATE TABLE $_customTriggersTable (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            previous_names_json TEXT NOT NULL DEFAULT '[]',
            position INTEGER NOT NULL
          )
        ''');
        },
      ),
    );
    return SqfliteMoodDatabase._(database);
  }

  @override
  Future<MoodRecord?> loadRecord(String dateKey) async {
    final records = await _loadRecords(
      where: 'date_key = ?',
      whereArgs: [dateKey],
    );
    return records.isEmpty ? null : records.first;
  }

  @override
  Future<List<MoodRecord>> loadRecords({
    String? startDateKey,
    String? endDateKey,
  }) {
    final clauses = <String>[];
    final arguments = <Object?>[];
    if (startDateKey != null) {
      clauses.add('date_key >= ?');
      arguments.add(startDateKey);
    }
    if (endDateKey != null) {
      clauses.add('date_key <= ?');
      arguments.add(endDateKey);
    }

    return _loadRecords(
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
    );
  }

  Future<List<MoodRecord>> _loadRecords({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final recordRows = await _database.query(
      _recordsTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date_key ASC',
    );
    if (recordRows.isEmpty) {
      return [];
    }

    final dateKeys = recordRows
        .map((row) => row['date_key']! as String)
        .toList();
    final placeholders = List.filled(dateKeys.length, '?').join(', ');
    final triggerRows = await _database.query(
      _recordTriggersTable,
      where: 'record_date_key IN ($placeholders)',
      whereArgs: dateKeys,
      orderBy: 'record_date_key ASC, position ASC',
    );
    final triggersByDate = <String, List<String>>{};
    for (final row in triggerRows) {
      final dateKey = row['record_date_key']! as String;
      final triggerName = row['trigger_name']! as String;
      triggersByDate.putIfAbsent(dateKey, () => []).add(triggerName);
    }

    return recordRows.map((row) {
      final dateKey = row['date_key']! as String;
      return MoodRecord(
        dateKey: dateKey,
        moodIndex: row['mood_index']! as int,
        energy: row['energy'] as String?,
        triggers: triggersByDate[dateKey] ?? const [],
        context: row['context']! as String,
      );
    }).toList();
  }

  @override
  Future<void> upsertRecord(MoodRecord record) async {
    await _database.transaction((transaction) async {
      await transaction.insert(_recordsTable, {
        'date_key': record.dateKey,
        'mood_index': record.moodIndex,
        'energy': record.energy,
        'context': record.context,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await transaction.delete(
        _recordTriggersTable,
        where: 'record_date_key = ?',
        whereArgs: [record.dateKey],
      );
      for (var index = 0; index < record.triggers.length; index++) {
        final trigger = record.triggers[index].trim();
        if (trigger.isEmpty) {
          continue;
        }
        await transaction.insert(_recordTriggersTable, {
          'record_date_key': record.dateKey,
          'trigger_name': trigger,
          'position': index,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  @override
  Future<void> deleteRecord(String dateKey) {
    return _database.delete(
      _recordsTable,
      where: 'date_key = ?',
      whereArgs: [dateKey],
    );
  }

  @override
  Future<List<CustomTrigger>> loadCustomTriggers() async {
    final rows = await _database.query(
      _customTriggersTable,
      orderBy: 'position ASC',
    );
    return rows.map((row) {
      final previousNamesRaw = row['previous_names_json']! as String;
      final previousNames = (jsonDecode(previousNamesRaw) as List<dynamic>)
          .whereType<String>()
          .toList();
      return CustomTrigger(
        id: row['id']! as String,
        name: row['name']! as String,
        previousNames: previousNames,
      );
    }).toList();
  }

  @override
  Future<void> replaceCustomTriggers(List<CustomTrigger> triggers) async {
    await _database.transaction((transaction) async {
      await transaction.delete(_customTriggersTable);
      for (var index = 0; index < triggers.length; index++) {
        final trigger = triggers[index];
        await transaction.insert(_customTriggersTable, {
          'id': trigger.id,
          'name': trigger.name,
          'previous_names_json': jsonEncode(trigger.previousNames),
          'position': index,
        });
      }
    });
  }

  @override
  Future<void> close() {
    return _database.close();
  }
}

class InMemoryMoodDatabase implements MoodDatabase {
  InMemoryMoodDatabase({
    Iterable<MoodRecord> records = const [],
    Iterable<CustomTrigger> customTriggers = const [],
  }) : _records = {for (final record in records) record.dateKey: record},
       _customTriggers = [...customTriggers];

  final Map<String, MoodRecord> _records;
  List<CustomTrigger> _customTriggers;

  @override
  Future<MoodRecord?> loadRecord(String dateKey) async {
    return _records[dateKey];
  }

  @override
  Future<List<MoodRecord>> loadRecords({
    String? startDateKey,
    String? endDateKey,
  }) async {
    final records = _records.values.where((record) {
      if (startDateKey != null && record.dateKey.compareTo(startDateKey) < 0) {
        return false;
      }
      if (endDateKey != null && record.dateKey.compareTo(endDateKey) > 0) {
        return false;
      }
      return true;
    }).toList()..sort((left, right) => left.dateKey.compareTo(right.dateKey));
    return records;
  }

  @override
  Future<void> upsertRecord(MoodRecord record) async {
    _records[record.dateKey] = record;
  }

  @override
  Future<void> deleteRecord(String dateKey) async {
    _records.remove(dateKey);
  }

  @override
  Future<List<CustomTrigger>> loadCustomTriggers() async {
    return [..._customTriggers];
  }

  @override
  Future<void> replaceCustomTriggers(List<CustomTrigger> triggers) async {
    _customTriggers = [...triggers];
  }

  @override
  Future<void> close() async {}
}
