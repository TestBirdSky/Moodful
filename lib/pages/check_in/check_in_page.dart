import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/widgets/app_page_header.dart';
import 'check_in_controller.dart';
import 'widgets/check_in_section.dart';
import 'widgets/energy_button.dart';
import 'widgets/mood_button.dart';
import 'widgets/save_button.dart';
import 'widgets/trigger_chip.dart';

class CheckInPage extends GetView<CheckInController> {
  const CheckInPage({super.key});

  static const _moods = [
    ('Great', 'assets/images/moods/mood_great.webp'),
    ('Good', 'assets/images/moods/mood_good.webp'),
    ('Okay', 'assets/images/moods/mood_okay.webp'),
    ('Low', 'assets/images/moods/mood_low.webp'),
    ('Bad', 'assets/images/moods/mood_bad.webp'),
  ];

  static const _energies = [
    ('High', 'assets/images/moods/energy_high.webp'),
    ('Normal', 'assets/images/moods/energy_normal.webp'),
    ('Low', 'assets/images/moods/energy_low.webp'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final buttonLabel = controller.hasTodayRecord.value
          ? 'Update check-in'
          : 'Save check-in';
      final subtitle = controller.hasTodayRecord.value
          ? 'Already checked today'
          : 'How are you feeling today?';
      final hasScrollableTriggers = controller.availableTriggers.length > 6;
      final navigationClearance =
          64.r + MediaQuery.viewPaddingOf(context).bottom;

      return SingleChildScrollView(
        key: const ValueKey('check-in-scroll'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          14.r,
          14.r,
          14.r,
          navigationClearance + 14.r,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(title: 'Today Check-in', subtitle: subtitle),
            SizedBox(height: 20.r),
            CheckInSection(
              title: 'Mood',
              titleFontSize: 14,
              height: 132.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var index = 0; index < _moods.length; index++)
                    MoodButton(
                      label: _moods[index].$1,
                      asset: _moods[index].$2,
                      selected: controller.selectedMoodIndex.value == index,
                      labelFontSize: 12,
                      onPressed: () => controller.selectMood(index),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12.r),
            CheckInSection(
              title: 'Energy',
              titleFontSize: 14,
              height: 119.r,
              child: Row(
                children: [
                  for (var index = 0; index < _energies.length; index++) ...[
                    Expanded(
                      child: EnergyButton(
                        label: _energies[index].$1,
                        asset: _energies[index].$2,
                        selected:
                            controller.selectedEnergy.value ==
                            _energies[index].$1,
                        labelFontSize: 12,
                        onPressed: () =>
                            controller.toggleEnergy(_energies[index].$1),
                      ),
                    ),
                    if (index != _energies.length - 1) SizedBox(width: 13.r),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12.r),
            CheckInSection(
              title: 'Triggers',
              titleFontSize: 14,
              height: (hasScrollableTriggers ? 138 : 118).r,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const columnCount = 3;
                  final horizontalSpacing = 7.r;
                  final chipWidth =
                      (constraints.maxWidth -
                          horizontalSpacing * (columnCount - 1)) /
                      columnCount;

                  return ListView(
                    key: const ValueKey('check-in-triggers-scroll'),
                    primary: false,
                    padding: EdgeInsets.zero,
                    physics: hasScrollableTriggers
                        ? const ClampingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    children: [
                      Wrap(
                        spacing: horizontalSpacing,
                        runSpacing: 7.r,
                        children: [
                          for (final trigger in controller.availableTriggers)
                            TriggerChip(
                              key: ValueKey('check-in-trigger-$trigger'),
                              label: trigger,
                              width: chipWidth,
                              selected: controller.selectedTriggers.contains(
                                trigger,
                              ),
                              labelFontSize: 12,
                              onPressed: () =>
                                  controller.toggleTrigger(trigger),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 12.r),
            CheckInSection(
              title: 'Context',
              titleFontSize: 14,
              height: 137.r,
              child: TextField(
                controller: controller.contextController,
                maxLength: 120,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  height: 1.4,
                  letterSpacing: 0,
                ),
                decoration: InputDecoration(
                  hintText: 'One short sentence...',
                  hintStyle: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                  counterText: '',
                  contentPadding: EdgeInsets.fromLTRB(12.r, 11.r, 12.r, 8.r),
                  filled: true,
                  fillColor: const Color(0x10FFFFFF),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: const BorderSide(
                      color: AppColors.outline,
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.r),
            SaveButton(
              key: const ValueKey('check-in-save-button'),
              label: buttonLabel,
              isSaving: controller.isSaving.value,
              enabled: controller.selectedMoodIndex.value != null,
              labelFontSize: 13,
              onPressed: controller.saveCheckIn,
            ),
          ],
        ),
      );
    });
  }
}
