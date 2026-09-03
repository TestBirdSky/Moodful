import 'package:get/get.dart';

import '../../models/mood_record.dart';

class WeeklyReviewController extends GetxController {
  WeeklyReviewController(this.records);

  final List<MoodRecord> records;
  final hiddenFocusTags = <String>{}.obs;

  static const _goodMoodTriggers = {'Friends', 'Walk'};

  int get checkInCount => records.length;

  int get lowDays {
    return records.where((record) => record.moodIndex >= 3).length;
  }

  String get mostCommonTrigger => _triggerCounts.isEmpty
      ? 'No trigger yet'
      : _triggerCounts.entries.first.key;

  List<String> get patterns {
    if (records.length < 3) {
      return const ['Not enough records yet.'];
    }

    final results = <String>[];
    final lowTriggerCounts = _triggerCountsFor(
      records.where((record) => record.moodIndex >= 3),
    );
    if (_isMostFrequent('Sleep', lowTriggerCounts)) {
      results.add('Low mood often followed poor sleep.');
    }

    final goodTriggerCounts = _triggerCountsFor(
      records.where((record) => record.moodIndex <= 1),
    );
    final hasFrequentPositiveTrigger = _goodMoodTriggers.any(
      (trigger) => _isMostFrequent(trigger, goodTriggerCounts),
    );
    if (hasFrequentPositiveTrigger) {
      results.add('Good mood appeared with friends/walk.');
    }

    if (results.isEmpty) {
      results.add('No clear pattern yet.');
    }
    return results;
  }

  List<String> get focusTags {
    return _triggerCounts.keys
        .where((tag) => !hiddenFocusTags.contains(tag))
        .take(3)
        .toList();
  }

  void hideFocusTag(String tag) {
    hiddenFocusTags.add(tag);
    update();
  }

  Map<String, int> get _triggerCounts {
    final counts = <String, int>{};
    for (final record in records) {
      for (final trigger in record.triggers) {
        if (trigger.trim().isNotEmpty) {
          counts[trigger] = (counts[trigger] ?? 0) + 1;
        }
      }
    }

    final entries = counts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    return {for (final entry in entries) entry.key: entry.value};
  }

  Map<String, int> _triggerCountsFor(Iterable<MoodRecord> source) {
    final counts = <String, int>{};
    for (final record in source) {
      for (final trigger in record.triggers) {
        if (trigger.trim().isNotEmpty) {
          counts[trigger] = (counts[trigger] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  bool _isMostFrequent(String trigger, Map<String, int> counts) {
    final triggerCount = counts[trigger] ?? 0;
    if (triggerCount == 0) {
      return false;
    }
    if (counts.isEmpty) {
      return false;
    }
    final maxCount = counts.values.reduce((current, next) {
      return next > current ? next : current;
    });
    return triggerCount == maxCount;
  }
}
