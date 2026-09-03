import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/widgets/app_page_header.dart';
import 'all_triggers_page.dart';
import 'triggers_controller.dart';

class TriggersPage extends GetView<TriggersController> {
  const TriggersPage({super.key});

  static const _progressColors = [
    AppColors.accent,
    Color(0xFFFFB45F),
    Color(0xFFB692EC),
    Color(0xFF73C7B4),
    Color(0xFFFF8F78),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 96.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppPageHeader(
              title: 'Triggers',
              subtitle: 'What appeared this week',
            ),
            SizedBox(height: 20.r),
            _TriggerSection(
              title: 'Top triggers',
              child: controller.topTriggers.isEmpty
                  ? const _EmptyState(label: 'No triggers this week')
                  : Column(
                      children: [
                        for (
                          var index = 0;
                          index < controller.topTriggers.length;
                          index++
                        ) ...[
                          _TopTriggerRow(
                            trigger: controller.topTriggers[index],
                            maximumCount: controller.topTriggers.first.count,
                            color: _progressColors[index],
                          ),
                          if (index != controller.topTriggers.length - 1)
                            SizedBox(height: 14.r),
                        ],
                      ],
                    ),
            ),
            SizedBox(height: 12.r),
            _TriggerSection(
              title: 'Triggers map',
              child: Column(
                children: [
                  _MoodTriggerRow(
                    label: 'Low mood',
                    triggers: controller.lowMoodTriggers,
                    chipColor: const Color(0xFFFFF0D8),
                    textColor: const Color(0xFFF5A11B),
                  ),
                  SizedBox(height: 14.r),
                  _MoodTriggerRow(
                    label: 'Good mood',
                    triggers: controller.goodMoodTriggers,
                    chipColor: const Color(0xFFEDE1FF),
                    textColor: const Color(0xFFA27ADA),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.r),
            SizedBox(
              height: 47.r,
              child: FilledButton(
                key: const ValueKey('manage-triggers-button'),
                onPressed: () => Get.to(() => const AllTriggersPage()),
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFFFDAD5),
                  foregroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                child: const Text('Manage trigger'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriggerSection extends StatelessWidget {
  const _TriggerSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 13.r, 16.r, 15.r),
      decoration: BoxDecoration(
        color: const Color(0xB8FFF9FB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xB8FFFFFF), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 13.r),
          child,
        ],
      ),
    );
  }
}

class _TopTriggerRow extends StatelessWidget {
  const _TopTriggerRow({
    required this.trigger,
    required this.maximumCount,
    required this.color,
  });

  final TriggerCount trigger;
  final int maximumCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = maximumCount == 0 ? 0.0 : trigger.count / maximumCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                trigger.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            ),
            SizedBox(width: 8.r),
            Text(
              '${trigger.count} ${trigger.count == 1 ? 'time' : 'times'}',
              style: const TextStyle(
                color: AppColors.mutedDark,
                fontSize: 11,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        SizedBox(height: 7.r),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7.r,
            backgroundColor: const Color(0x14BCA9B1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _MoodTriggerRow extends StatelessWidget {
  const _MoodTriggerRow({
    required this.label,
    required this.triggers,
    required this.chipColor,
    required this.textColor,
  });

  final String label;
  final List<TriggerCount> triggers;
  final Color chipColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70.r,
          child: Padding(
            padding: EdgeInsets.only(top: 8.r),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        Expanded(
          child: triggers.isEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: 8.r),
                  child: const Text(
                    'No data yet',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final chipWidth = (constraints.maxWidth - 7.r) / 2;
                    return Wrap(
                      spacing: 7.r,
                      runSpacing: 7.r,
                      children: [
                        for (final trigger in triggers)
                          SizedBox(
                            key: ValueKey('trigger-map-$label-${trigger.name}'),
                            width: chipWidth,
                            height: 30.r,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: chipColor,
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.r),
                                child: Center(
                                  child: Text(
                                    trigger.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      height: 1.2,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 13.r),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
