import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants/app_storage_keys.dart';
import '../models/custom_trigger.dart';
import '../models/mood_record.dart';
import 'mood_database.dart';

class LocalStorageService {
  LocalStorageService(this._preferences, {MoodDatabase? database})
    : _database = database ?? InMemoryMoodDatabase();

  LocalStorageService.inMemory({
    Iterable<MoodRecord> records = const [],
    Iterable<CustomTrigger> customTriggers = const [],
  }) : _preferences = null,
       _database = InMemoryMoodDatabase(
         records: records,
         customTriggers: customTriggers,
       );

  static const onboardingSeenKey = AppStorageKeys.onboardingSeen;

  final SharedPreferences? _preferences;
  final MoodDatabase _database;
  final Map<String, Object> _memoryValues = {};

  static Future<SharedPreferences> createPreferences() {
    return SharedPreferences.getInstance();
  }

  static Future<LocalStorageService> create() async {
    SharedPreferences? preferences;
    try {
      preferences = await createPreferences().timeout(
        const Duration(seconds: 3),
      );
    } catch (error, stackTrace) {
      debugPrint('Unable to open app preferences: $error\n$stackTrace');
    }

    try {
      final database = await SqfliteMoodDatabase.open().timeout(
        const Duration(seconds: 5),
      );
      return LocalStorageService(preferences, database: database);
    } catch (error, stackTrace) {
      debugPrint('Unable to open Mood database: $error\n$stackTrace');
      return LocalStorageService(preferences);
    }
  }

  bool get hasSeenOnboarding {
    return _getBool(AppStorageKeys.onboardingSeen) ?? false;
  }

  Future<void> markOnboardingSeen() {
    return _setBool(AppStorageKeys.onboardingSeen, true);
  }

  Future<MoodRecord?> loadTodayRecord({DateTime? onDate}) {
    final dateKey = MoodRecord.dateKeyFor(onDate ?? DateTime.now());
    return _database.loadRecord(dateKey);
  }

  Future<List<MoodRecord>> loadRecentRecords({DateTime? from}) {
    final anchor = from ?? DateTime.now();
    final end = DateTime(anchor.year, anchor.month, anchor.day);
    final start = end.subtract(const Duration(days: 6));
    return _database.loadRecords(
      startDateKey: MoodRecord.dateKeyFor(start),
      endDateKey: MoodRecord.dateKeyFor(end),
    );
  }

  Future<List<MoodRecord>> loadAllRecords() {
    return _database.loadRecords();
  }

  Future<void> saveTodayRecord(MoodRecord record) {
    return _database.upsertRecord(record);
  }

  Future<void> deleteRecord(String dateKey) {
    return _database.deleteRecord(dateKey);
  }

  Future<List<CustomTrigger>> loadCustomTriggers() {
    return _database.loadCustomTriggers();
  }

  Future<void> saveCustomTriggers(List<CustomTrigger> triggers) {
    return _database.replaceCustomTriggers(triggers);
  }

  Future<void> close() {
    return _database.close();
  }

  bool? _getBool(String key) {
    return _preferences?.getBool(key) ?? _memoryValues[key] as bool?;
  }

  Future<void> _setBool(String key, bool value) async {
    final preferences = _preferences;
    if (preferences == null) {
      _memoryValues[key] = value;
      return;
    }
    await preferences.setBool(key, value);
  }
}
