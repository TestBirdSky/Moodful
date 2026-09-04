import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:recordmood/app/app.dart';
import 'package:recordmood/app/bootstrap_app.dart';
import 'package:recordmood/common/constants/app_assets.dart';
import 'package:recordmood/common/constants/app_storage_keys.dart';
import 'package:recordmood/models/custom_trigger.dart';
import 'package:recordmood/models/mood_record.dart';
import 'package:recordmood/pages/check_in/check_in_controller.dart';
import 'package:recordmood/pages/main/main_shell_page.dart';
import 'package:recordmood/pages/startup/startup_page.dart';
import 'package:recordmood/services/local_storage_service.dart';
import 'package:recordmood/services/mood_database.dart';

class _HangingSaveStorage extends LocalStorageService {
  _HangingSaveStorage() : super.inMemory();

  final Completer<void> saveCompleter = Completer<void>();

  @override
  Future<void> saveTodayRecord(MoodRecord record) {
    return saveCompleter.future;
  }
}

Future<MoodfulApp> _createApp({
  Map<String, Object> initialValues = const {},
  Duration hotStartThreshold = const Duration(seconds: 3),
  Duration hotStartSplashDuration = StartupPage.minimumDisplayDuration,
  DateTime Function()? now,
  LocalStorageService? storage,
  Iterable<MoodRecord> records = const [],
  Iterable<CustomTrigger> customTriggers = const [],
}) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  return MoodfulApp(
    storage:
        storage ??
        LocalStorageService(
          preferences,
          database: InMemoryMoodDatabase(
            records: records,
            customTriggers: customTriggers,
          ),
        ),
    hotStartThreshold: hotStartThreshold,
    hotStartSplashDuration: hotStartSplashDuration,
    now: now,
  );
}

void _sendAppToBackground(WidgetTester tester) {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
}

void _resumeApp(WidgetTester tester) {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
}

void main() {
  tearDown(() async {
    Get.reset();
  });

  testWidgets('startup remains responsive while storage is loading', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      AppStorageKeys.onboardingSeen: true,
    });
    final preferences = await SharedPreferences.getInstance();
    final storageCompleter = Completer<LocalStorageService>();

    await tester.pumpWidget(
      MoodfulBootstrapApp(
        storageLoader: () => storageCompleter.future,
        minimumSplashDuration: Duration.zero,
      ),
    );

    expect(find.byType(StartupPage), findsOneWidget);
    expect(
      find.byKey(const ValueKey('startup-progress-indicator')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('startup-progress-fill')), findsOneWidget);
    final progressRect = tester.getRect(
      find.byKey(const ValueKey('startup-progress-indicator')),
    );
    expect(progressRect.width, greaterThan(0));
    expect(progressRect.bottom, lessThan(760));

    storageCompleter.complete(LocalStorageService(preferences));
    await tester.pumpAndSettle();

    expect(find.byType(StartupPage), findsNothing);
    expect(find.byType(MainShellPage), findsOneWidget);
  });

  testWidgets('startup blocks the system back button', (
    WidgetTester tester,
  ) async {
    final storageCompleter = Completer<LocalStorageService>();
    await tester.pumpWidget(
      MoodfulBootstrapApp(
        storageLoader: () => storageCompleter.future,
        minimumSplashDuration: Duration.zero,
      ),
    );
    await tester.pump();

    expect(find.byType(StartupPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(StartupPage), findsOneWidget);

    storageCompleter.complete(LocalStorageService.inMemory());
    await tester.pump();
  });

  testWidgets('startup falls back instead of hanging when storage fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MoodfulBootstrapApp(
        storageLoader: () => Future<LocalStorageService>.error(
          StateError('storage unavailable'),
        ),
        minimumSplashDuration: Duration.zero,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StartupPage), findsNothing);
    expect(find.textContaining('Take a quiet moment to'), findsOneWidget);
  });

  testWidgets('cold startup remains visible for at least three seconds', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      AppStorageKeys.onboardingSeen: true,
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MoodfulBootstrapApp(
        storageLoader: () async => LocalStorageService(preferences),
      ),
    );
    await tester.pump();

    expect(find.byType(StartupPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2999));
    expect(find.byType(StartupPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    expect(find.byType(StartupPage), findsNothing);
    expect(find.byType(MainShellPage), findsOneWidget);
  });

  testWidgets('hot start shows startup after three seconds in background', (
    WidgetTester tester,
  ) async {
    var now = DateTime(2026, 9, 2, 12);
    await tester.pumpWidget(
      await _createApp(
        initialValues: {AppStorageKeys.onboardingSeen: true},
        now: () => now,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Rate App'), findsOneWidget);

    _sendAppToBackground(tester);
    now = now.add(const Duration(seconds: 3));
    _resumeApp(tester);
    await tester.pump();
    await tester.pump();

    expect(find.byType(StartupPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2999));
    expect(find.byType(StartupPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    expect(find.byType(StartupPage), findsNothing);
    expect(find.text('Rate App'), findsOneWidget);
  });

  testWidgets('hot start skips startup before three seconds', (
    WidgetTester tester,
  ) async {
    var now = DateTime(2026, 9, 2, 12);
    await tester.pumpWidget(
      await _createApp(
        initialValues: {AppStorageKeys.onboardingSeen: true},
        now: () => now,
      ),
    );
    await tester.pumpAndSettle();

    _sendAppToBackground(tester);
    now = now.add(const Duration(milliseconds: 2999));
    _resumeApp(tester);
    await tester.pump();
    await tester.pump();

    expect(find.byType(StartupPage), findsNothing);
    expect(find.byType(MainShellPage), findsOneWidget);
  });

  testWidgets('first launch shows onboarding and opens the main shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _createApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Take a quiet moment to'), findsOneWidget);
    expect(find.text("Begin today's check-in"), findsOneWidget);
    expect(find.byType(MainShellPage), findsNothing);

    await tester.tap(find.text("Begin today's check-in"));
    await tester.pumpAndSettle();

    expect(find.byType(MainShellPage), findsOneWidget);
  });

  testWidgets('onboarding blocks the system back button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _createApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Take a quiet moment to'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.textContaining('Take a quiet moment to'), findsOneWidget);
  });

  testWidgets('returning user sees the five navigation items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      await _createApp(initialValues: {AppStorageKeys.onboardingSeen: true}),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MainShellPage), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Board'), findsOneWidget);
    expect(find.text('Triggers'), findsNWidgets(2));
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('History').last);
    await tester.pump();
    expect(
      find.text('Your check-in history will appear here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Settings'));
    await tester.pump();

    expect(find.text('Rate App'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Mood scale'), findsNothing);
    expect(find.textContaining('Version'), findsOneWidget);
  });

  for (final size in const [ui.Size(360, 760), ui.Size(430, 932)]) {
    testWidgets(
      'main pages render without overflow at ${size.width}x${size.height}',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          await _createApp(
            initialValues: {AppStorageKeys.onboardingSeen: true},
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        for (final tab in const ['Board', 'Triggers', 'History', 'Settings']) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('main header uses 18 and 12 font sizes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      await _createApp(initialValues: {AppStorageKeys.onboardingSeen: true}),
    );
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text('Today Check-in'));
    final subtitle = tester.widget<Text>(
      find.text('How are you feeling today?'),
    );
    expect(title.style?.fontSize, 18);
    expect(subtitle.style?.fontSize, 12);
  });

  testWidgets('check-in save button stays fixed while form scrolls', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const ui.Size(360, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _createApp(initialValues: {AppStorageKeys.onboardingSeen: true}),
    );
    await tester.pumpAndSettle();

    final scroll = find.byKey(const ValueKey('check-in-scroll'));
    final saveButton = find.byKey(const ValueKey('check-in-save-button'));
    final contextTitle = find.text('Context');
    final saveButtonY = tester.getTopLeft(saveButton).dy;
    final contextTitleY = tester.getTopLeft(contextTitle).dy;

    await tester.drag(scroll, const Offset(0, -160));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(saveButton).dy, closeTo(saveButtonY, 0.5));
    expect(tester.getTopLeft(contextTitle).dy, lessThan(contextTitleY));
  });

  testWidgets('check-in triggers scroll inside the section after six items', (
    WidgetTester tester,
  ) async {
    final customTriggers = List.generate(
      4,
      (index) =>
          CustomTrigger(id: 'custom-$index', name: 'Custom ${index + 1}'),
    );
    await tester.binding.setSurfaceSize(const ui.Size(360, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _createApp(
        initialValues: {AppStorageKeys.onboardingSeen: true},
        customTriggers: customTriggers,
      ),
    );
    await tester.pumpAndSettle();

    final scroll = find.byKey(const ValueKey('check-in-triggers-scroll'));
    Finder triggerBlock(String label) {
      return find
          .ancestor(
            of: find.text(label),
            matching: find.byType(AnimatedContainer),
          )
          .first;
    }

    final viewport = tester.getRect(scroll);
    final sleep = tester.getRect(triggerBlock('Sleep'));
    final work = tester.getRect(triggerBlock('Work'));
    final family = tester.getRect(triggerBlock('Family'));
    expect(sleep.width, closeTo(work.width, 0.5));
    expect(work.width, closeTo(family.width, 0.5));
    expect(family.right, closeTo(viewport.right, 0.5));

    final thirdRowFirst = tester.getRect(triggerBlock('Custom 1'));
    expect(thirdRowFirst.top, lessThan(viewport.bottom));
    expect(thirdRowFirst.bottom, greaterThan(viewport.bottom));

    final lastTrigger = find.text('Custom 4');
    final before = tester.getTopLeft(lastTrigger).dy;

    await tester.drag(scroll, const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(lastTrigger).dy, lessThan(before));
  });

  testWidgets('trigger map renders two tags on each row', (
    WidgetTester tester,
  ) async {
    final record = MoodRecord(
      dateKey: MoodRecord.dateKeyFor(DateTime.now()),
      moodIndex: 4,
      energy: 'Low',
      triggers: const ['Sleep', 'Work', 'Weather'],
      context: '',
    );
    await tester.pumpWidget(
      await _createApp(
        initialValues: {AppStorageKeys.onboardingSeen: true},
        records: [record],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Triggers').last);
    await tester.pumpAndSettle();

    final first = tester.getTopLeft(
      find.byKey(const ValueKey('trigger-map-Low mood-Sleep')),
    );
    final second = tester.getTopLeft(
      find.byKey(const ValueKey('trigger-map-Low mood-Weather')),
    );
    expect(second.dy, closeTo(first.dy, 0.5));
    expect(second.dx, greaterThan(first.dx));
  });

  testWidgets('all triggers keeps header and add button fixed', (
    WidgetTester tester,
  ) async {
    final customTriggers = List.generate(
      8,
      (index) => CustomTrigger(id: 'fixed-$index', name: 'Fixed ${index + 1}'),
    );
    await tester.binding.setSurfaceSize(const ui.Size(360, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _createApp(
        initialValues: {AppStorageKeys.onboardingSeen: true},
        customTriggers: customTriggers,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Triggers').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('manage-triggers-button')));
    await tester.pumpAndSettle();

    final header = find.byKey(const ValueKey('all-triggers-header'));
    final list = find.byKey(const ValueKey('all-triggers-list'));
    final button = find.byKey(const ValueKey('add-custom-trigger-button'));
    final headerY = tester.getTopLeft(header).dy;
    final buttonY = tester.getTopLeft(button).dy;

    await tester.drag(list, const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(header).dy, closeTo(headerY, 0.5));
    expect(tester.getTopLeft(button).dy, closeTo(buttonY, 0.5));
  });

  testWidgets('saving today check-in switches to update mode', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const ui.Size(360, 973));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _createApp(initialValues: {AppStorageKeys.onboardingSeen: true}),
    );
    await tester.pumpAndSettle();

    expect(find.text('Save check-in'), findsOneWidget);
    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();

    expect(find.text('Mood Board'), findsOneWidget);
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly Review'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Mood Board'), findsOneWidget);
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('Update check-in'), findsOneWidget);
    expect(find.text('Already checked today'), findsOneWidget);
  });

  testWidgets('save timeout always stops the loading indicator', (
    WidgetTester tester,
  ) async {
    final storage = _HangingSaveStorage();
    await storage.markOnboardingSeen();
    await tester.pumpWidget(await _createApp(storage: storage));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save check-in'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    final controller = Get.find<CheckInController>();
    expect(controller.isSaving.value, isFalse);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Save check-in'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('weekly review refreshes and analyzes five recent records', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const ui.Size(360, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime.now();
    final records = [
      MoodRecord(
        dateKey: MoodRecord.dateKeyFor(today),
        moodIndex: 4,
        energy: 'Low',
        triggers: const ['Sleep'],
        context: '',
      ),
      MoodRecord(
        dateKey: MoodRecord.dateKeyFor(today.subtract(const Duration(days: 1))),
        moodIndex: 3,
        energy: 'Low',
        triggers: const ['Sleep'],
        context: '',
      ),
      MoodRecord(
        dateKey: MoodRecord.dateKeyFor(today.subtract(const Duration(days: 2))),
        moodIndex: 0,
        energy: 'High',
        triggers: const ['Friends'],
        context: '',
      ),
      MoodRecord(
        dateKey: MoodRecord.dateKeyFor(today.subtract(const Duration(days: 3))),
        moodIndex: 1,
        energy: 'High',
        triggers: const ['Walk'],
        context: '',
      ),
      MoodRecord(
        dateKey: MoodRecord.dateKeyFor(today.subtract(const Duration(days: 4))),
        moodIndex: 1,
        energy: 'Normal',
        triggers: const ['Friends'],
        context: '',
      ),
    ];

    await tester.pumpWidget(
      await _createApp(
        initialValues: {AppStorageKeys.onboardingSeen: true},
        records: records,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Board'));
    await tester.pump();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.text('Not enough records yet.'), findsNothing);
    expect(
      find.textContaining('Low mood often followed poor sleep.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Good mood appeared with friends/walk.'),
      findsOneWidget,
    );

    final checkInsLabel = tester.widget<Text>(find.text('Check-ins'));
    expect(checkInsLabel.style?.fontSize, 12);
    expect(checkInsLabel.style?.color, const Color(0xFF7E636B));

    final checkInCount = tester.widget<Text>(find.text('5'));
    expect(checkInCount.style?.fontSize, 16);

    for (final asset in const [
      AppAssets.reviewCheckIns,
      'assets/images/onboarding/energy.webp',
      'assets/images/onboarding/triggers.webp',
    ]) {
      final image = tester.widget<Image>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == asset,
        ),
      );
      expect(image.width, 32.r);
      expect(image.height, 32.r);
    }

    final patternText = tester.widget<Text>(
      find.textContaining('Low mood often followed poor sleep.'),
    );
    expect(patternText.style?.fontSize, 14);
    expect(patternText.style?.color, const Color(0xFF332328));

    final patternHint = tester.widget<Text>(
      find.text('No medical diagnosis is shown here.'),
    );
    expect(patternHint.style?.fontSize, 12);
    expect(patternHint.style?.color, const Color(0xFF845966));

    final focusTitle = tester.widget<Text>(find.text('Next week focus'));
    expect(focusTitle.style?.fontSize, 16);
    expect(focusTitle.style?.color, const Color(0xFF332328));

    final sunImage = tester.widget<Image>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                AppAssets.reviewPatternSun,
      ),
    );
    expect(sunImage.width, 76.r);
    expect(sunImage.height, 76.r);
  });

  testWidgets('weekly review focus grows for long trigger names', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const ui.Size(360, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final longTrigger = 'Very long custom trigger name that should wrap safely';
    final records = [
      MoodRecord(
        dateKey: MoodRecord.dateKeyFor(DateTime.now()),
        moodIndex: 2,
        energy: 'Normal',
        triggers: [longTrigger],
        context: '',
      ),
    ];

    await tester.pumpWidget(
      await _createApp(
        initialValues: {AppStorageKeys.onboardingSeen: true},
        records: records,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Board'));
    await tester.pump();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    final focusCard = find
        .ancestor(
          of: find.text('Next week focus'),
          matching: find.byType(Container),
        )
        .first;
    expect(tester.getSize(focusCard).height, greaterThan(117.r));
    expect(find.text(longTrigger), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home triggers allow multiple selections', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const ui.Size(360, 973));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _createApp(initialValues: {AppStorageKeys.onboardingSeen: true}),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<CheckInController>();
    expect(controller.selectedTriggers, isEmpty);

    await tester.tap(find.text('Sleep'));
    await tester.pump();
    expect(controller.selectedTriggers, {'Sleep'});

    await tester.tap(find.text('Work'));
    await tester.pump();
    expect(controller.selectedTriggers, {'Sleep', 'Work'});

    await tester.tap(find.text('Work'));
    await tester.pump();
    expect(controller.selectedTriggers, {'Sleep'});
  });

  testWidgets('custom triggers can be added, edited, used, and deleted', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const ui.Size(360, 973));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _createApp(initialValues: {AppStorageKeys.onboardingSeen: true}),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Triggers').last);
    await tester.pumpAndSettle();
    expect(find.text('Top triggers'), findsOneWidget);
    expect(find.text('Triggers map'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('manage-triggers-button')));
    await tester.pumpAndSettle();
    expect(find.text('All Triggers'), findsOneWidget);
    expect(find.text('Locked'), findsNWidgets(6));
    expect(find.text('No custom triggers yet'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('add-custom-trigger-button')),
    );
    await tester.tap(find.byKey(const ValueKey('add-custom-trigger-button')));
    await tester.pumpAndSettle();
    expect(find.text('Add trigger'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('trigger-name-field')),
      'Commute',
    );
    await tester.tap(find.byKey(const ValueKey('save-trigger-button')));
    await tester.pumpAndSettle();

    expect(find.text('Commute'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Locked'), findsNWidgets(6));

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit trigger'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('trigger-name-field')),
      'Travel',
    );
    await tester.tap(find.byKey(const ValueKey('save-trigger-button')));
    await tester.pumpAndSettle();

    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Commute'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('all-triggers-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Commute'), findsNothing);

    await tester.tap(find.text('Triggers').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('manage-triggers-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('delete-trigger-button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('confirm-delete-trigger-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Travel'), findsNothing);
    expect(find.text('No custom triggers yet'), findsOneWidget);
  });
}
