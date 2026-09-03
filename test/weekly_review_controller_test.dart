import 'package:flutter_test/flutter_test.dart';

import 'package:recordmood/models/mood_record.dart';
import 'package:recordmood/pages/board/weekly_review_controller.dart';

MoodRecord _record({
  required String dateKey,
  required int moodIndex,
  List<String> triggers = const [],
}) {
  return MoodRecord(
    dateKey: dateKey,
    moodIndex: moodIndex,
    energy: 'Normal',
    triggers: triggers,
    context: '',
  );
}

void main() {
  test('shows an insufficient-data pattern below three check-ins', () {
    final controller = WeeklyReviewController([
      _record(dateKey: '2026-08-31', moodIndex: 1),
      _record(dateKey: '2026-09-01', moodIndex: 2),
    ]);

    expect(controller.patterns, ['Not enough records yet.']);
  });

  test('finds simple sleep and positive-activity patterns', () {
    final controller = WeeklyReviewController([
      _record(dateKey: '2026-08-29', moodIndex: 4, triggers: ['Sleep']),
      _record(dateKey: '2026-08-30', moodIndex: 3, triggers: ['Sleep']),
      _record(dateKey: '2026-08-31', moodIndex: 0, triggers: ['Friends']),
      _record(dateKey: '2026-09-01', moodIndex: 1, triggers: ['Friends']),
      _record(dateKey: '2026-09-02', moodIndex: 1, triggers: ['Walk']),
    ]);

    expect(controller.checkInCount, 5);
    expect(controller.lowDays, 2);
    expect(controller.mostCommonTrigger, 'Sleep');
    expect(
      controller.patterns,
      contains('Low mood often followed poor sleep.'),
    );
    expect(
      controller.patterns,
      contains('Good mood appeared with friends/walk.'),
    );
    expect(controller.focusTags, ['Sleep', 'Friends', 'Walk']);

    controller.hideFocusTag('Sleep');
    expect(controller.focusTags, ['Friends', 'Walk']);
  });

  test('positive trigger must be most frequent on good mood days', () {
    final controller = WeeklyReviewController([
      _record(dateKey: '2026-08-29', moodIndex: 0, triggers: ['Work']),
      _record(dateKey: '2026-08-30', moodIndex: 1, triggers: ['Work']),
      _record(dateKey: '2026-08-31', moodIndex: 0, triggers: ['Friends']),
    ]);

    expect(
      controller.patterns,
      isNot(contains('Good mood appeared with friends/walk.')),
    );
  });
}
