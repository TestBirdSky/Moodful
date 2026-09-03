import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:recordmood/app/app.dart';
import 'package:recordmood/common/constants/app_storage_keys.dart';
import 'package:recordmood/models/mood_record.dart';
import 'package:recordmood/services/local_storage_service.dart';
import 'package:recordmood/services/mood_database.dart';

bool _isTriggerSelected(WidgetTester tester, Finder trigger) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(of: trigger, matching: find.byType(AnimatedContainer)),
  );
  final decoration = container.decoration as BoxDecoration;
  return decoration.border != null;
}

void main() {
  tearDown(() async {
    Get.reset();
  });

  testWidgets('history opens detail, edit returns to detail, and deletes', (
    WidgetTester tester,
  ) async {
    final record = MoodRecord(
      dateKey: MoodRecord.dateKeyFor(DateTime.now()),
      moodIndex: 2,
      energy: 'Normal',
      triggers: const ['Sleep', 'Work'],
      context: 'Slept late, work meeting in morning',
    );
    SharedPreferences.setMockInitialValues({
      AppStorageKeys.onboardingSeen: true,
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MoodfulApp(
        storage: LocalStorageService(
          preferences,
          database: InMemoryMoodDatabase(records: [record]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('history-record-${record.dateKey}')));
    await tester.pumpAndSettle();
    expect(find.text('Record Detail'), findsOneWidget);
    expect(find.text('Triggers map'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Record'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    expect(find.text('Save changes'), findsOneWidget);

    final sleep = find.byKey(const ValueKey('history-edit-trigger-Sleep'));
    final work = find.byKey(const ValueKey('history-edit-trigger-Work'));
    final family = find.byKey(const ValueKey('history-edit-trigger-Family'));
    final weather = find.byKey(const ValueKey('history-edit-trigger-Weather'));
    expect(
      tester.getTopLeft(work).dy,
      closeTo(tester.getTopLeft(sleep).dy, 0.5),
    );
    expect(
      tester.getTopLeft(family).dy,
      closeTo(tester.getTopLeft(sleep).dy, 0.5),
    );
    expect(
      tester.getTopLeft(weather).dy,
      greaterThan(tester.getTopLeft(sleep).dy),
    );
    expect(_isTriggerSelected(tester, sleep), isTrue);
    expect(_isTriggerSelected(tester, work), isTrue);

    await tester.tap(work);
    await tester.pump();
    expect(_isTriggerSelected(tester, sleep), isTrue);
    expect(_isTriggerSelected(tester, work), isFalse);

    await tester.tap(family);
    await tester.pump();
    expect(_isTriggerSelected(tester, sleep), isTrue);
    expect(_isTriggerSelected(tester, family), isTrue);

    await tester.tap(find.byKey(const ValueKey('history-edit-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Record Detail'), findsOneWidget);
    expect(find.text('Edit Record'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('delete-record-button')));
    await tester.pumpAndSettle();
    expect(find.text('Delete record?'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('confirm-delete-record-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Record Detail'), findsNothing);
    expect(find.text('History').last, findsOneWidget);
    expect(
      find.byKey(ValueKey('history-record-${record.dateKey}')),
      findsNothing,
    );
  });

  testWidgets(
    'history detail and edit headers stay fixed while content scrolls',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 520));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final record = MoodRecord(
        dateKey: MoodRecord.dateKeyFor(DateTime.now()),
        moodIndex: 2,
        energy: 'Normal',
        triggers: const ['Sleep', 'Work'],
        context: 'A longer note used to verify the fixed history headers.',
      );
      SharedPreferences.setMockInitialValues({
        AppStorageKeys.onboardingSeen: true,
      });
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MoodfulApp(
          storage: LocalStorageService(
            preferences,
            database: InMemoryMoodDatabase(records: [record]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('History').last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(ValueKey('history-record-${record.dateKey}')),
      );
      await tester.pumpAndSettle();

      final detailHeader = find.byKey(const ValueKey('history-detail-header'));
      final detailHeaderY = tester.getTopLeft(detailHeader).dy;
      final detailBodyY = tester
          .getTopLeft(find.textContaining('${DateTime.now().year}'))
          .dy;
      await tester.drag(
        find.byKey(const ValueKey('history-detail-scroll')),
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(detailHeader).dy, closeTo(detailHeaderY, 0.5));
      expect(
        tester.getTopLeft(find.textContaining('${DateTime.now().year}')).dy,
        lessThan(detailBodyY),
      );

      final editButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Edit'),
      );
      expect(editButton.style?.textStyle?.resolve({})?.fontSize, 13);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      final editHeader = find.byKey(const ValueKey('history-edit-header'));
      final editHeaderY = tester.getTopLeft(editHeader).dy;
      await tester.drag(
        find.byKey(const ValueKey('history-edit-scroll')),
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(editHeader).dy, closeTo(editHeaderY, 0.5));
      expect(find.text('Save'), findsNothing);
      expect(find.text('Save changes'), findsOneWidget);
    },
  );

  testWidgets('history record card shows at most three triggers', (
    WidgetTester tester,
  ) async {
    final record = MoodRecord(
      dateKey: MoodRecord.dateKeyFor(DateTime.now()),
      moodIndex: 2,
      energy: 'Normal',
      triggers: const ['Sleep', 'Work', 'Weather', 'Money'],
      context: '',
    );
    SharedPreferences.setMockInitialValues({
      AppStorageKeys.onboardingSeen: true,
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MoodfulApp(
        storage: LocalStorageService(
          preferences,
          database: InMemoryMoodDatabase(records: [record]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    for (final trigger in const ['Sleep', 'Work', 'Weather']) {
      expect(
        find.byKey(
          ValueKey('history-record-${record.dateKey}-trigger-$trigger'),
        ),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(ValueKey('history-record-${record.dateKey}-trigger-Money')),
      findsNothing,
    );
  });
}
