import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/constants/app_assets.dart';
import '../../common/widgets/app_back_button.dart';
import '../../models/mood_record.dart';
import 'weekly_review_controller.dart';

class WeeklyReviewPage extends StatelessWidget {
  const WeeklyReviewPage({required this.records, super.key});

  final List<MoodRecord> records;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WeeklyReviewController>(
      init: WeeklyReviewController(records),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(9.r, 4.r, 9.r, 28.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReviewHeader(onBack: Get.back),
                  SizedBox(height: 18.r),
                  _OverviewCard(controller: controller),
                  SizedBox(height: 12.r),
                  _PatternsCard(controller: controller),
                  SizedBox(height: 12.r),
                  _FocusCard(controller: controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.r,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back',
            child: AppBackButton(onPressed: onBack),
          ),
          SizedBox(width: 5.r),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Review',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'From Mood Board',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.controller});

  final WeeklyReviewController controller;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      height: 125.r,
      child: Row(
        children: [
          Expanded(
            child: _ReviewStat(
              asset: AppAssets.reviewCheckIns,
              value: '${controller.checkInCount}',
              label: 'Check-ins',
            ),
          ),
          SizedBox(width: 7.r),
          Expanded(
            child: _ReviewStat(
              asset: 'assets/images/onboarding/energy.webp',
              value: '${controller.lowDays}',
              label: 'Low days',
            ),
          ),
          SizedBox(width: 7.r),
          Expanded(
            child: _ReviewStat(
              asset: 'assets/images/onboarding/triggers.webp',
              value: controller.mostCommonTrigger,
              label: 'Top trigger',
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStat extends StatelessWidget {
  const _ReviewStat({
    required this.asset,
    required this.value,
    required this.label,
  });

  final String asset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 7.r),
      decoration: BoxDecoration(
        color: const Color(0xE8FFFFFF),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            asset,
            width: 32.r,
            height: 32.r,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(height: 3.r),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 3.r),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7E636B),
              fontSize: 12,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternsCard extends StatelessWidget {
  const _PatternsCard({required this.controller});

  final WeeklyReviewController controller;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      height: 109.r,
      padding: EdgeInsets.fromLTRB(16.r, 14.r, 12.r, 12.r),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 72.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    controller.patterns.join('\n'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF332328),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(height: 4.r),
                const Text(
                  'No medical diagnosis is shown here.',
                  style: TextStyle(
                    color: Color(0xFF845966),
                    fontSize: 12,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: -2,
            child: Image.asset(
              AppAssets.reviewPatternSun,
              width: 76.r,
              height: 76.r,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.controller});

  final WeeklyReviewController controller;

  @override
  Widget build(BuildContext context) {
    final tags = controller.focusTags;
    return _ReviewCard(
      padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Next week focus',
            style: TextStyle(
              color: Color(0xFF332328),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 11.r),
          if (tags.isEmpty)
            const Text(
              'No focus tags yet',
              style: TextStyle(
                color: AppColors.mutedDark,
                fontSize: 10,
                height: 1.2,
                letterSpacing: 0,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 7.r,
                  runSpacing: 7.r,
                  children: [
                    for (final tag in tags)
                      _FocusTag(
                        label: tag,
                        maxWidth: constraints.maxWidth,
                        onRemove: () => controller.hideFocusTag(tag),
                      ),
                  ],
                );
              },
            ),
          SizedBox(height: 14.r),
          const Text(
            'Focus tags are optional reminders only.',
            style: TextStyle(
              color: AppColors.mutedDark,
              fontSize: 9.5,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusTag extends StatelessWidget {
  const _FocusTag({
    required this.label,
    required this.maxWidth,
    required this.onRemove,
  });

  final String label;
  final double maxWidth;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Dismiss $label focus',
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(18.r),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 74.r, maxWidth: maxWidth),
          child: Container(
            padding: EdgeInsets.fromLTRB(14.r, 7.r, 8.r, 7.r),
            decoration: BoxDecoration(
              color: const Color(0xD8FFFFFF),
              border: Border.all(
                color: label == 'Sleep'
                    ? AppColors.accent
                    : const Color(0x00FFFFFF),
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    softWrap: true,
                    style: TextStyle(
                      color: label == 'Sleep'
                          ? AppColors.accent
                          : AppColors.mutedDark,
                      fontSize: 11,
                      height: 1.1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(width: 6.r),
                Icon(
                  Icons.close_rounded,
                  size: 13.r,
                  color: label == 'Sleep'
                      ? AppColors.accent
                      : AppColors.mutedDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({this.height, required this.child, this.padding});

  final double? height;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? EdgeInsets.fromLTRB(12.r, 12.r, 12.r, 12.r),
      decoration: BoxDecoration(
        color: const Color(0xB8FFF9FB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xB8FFFFFF), width: 0.7),
      ),
      child: child,
    );
  }
}
