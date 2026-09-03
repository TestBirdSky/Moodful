import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/widgets/app_page_header.dart';
import '../../models/mood_record.dart';
import '../main/main_shell_controller.dart';
import 'board_controller.dart';
import 'weekly_review_page.dart';

class BoardPage extends GetView<BoardController> {
  const BoardPage({super.key});

  static const _moods = [
    ('Great', 'assets/images/moods/mood_great.webp'),
    ('Good', 'assets/images/moods/mood_good.webp'),
    ('Okay', 'assets/images/moods/mood_okay.webp'),
    ('Low', 'assets/images/moods/mood_low.webp'),
    ('Bad', 'assets/images/moods/mood_bad.webp'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 90.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: 'Mood Board',
              subtitle: 'last 7 days',
              trailing: _TextAction(
                label: 'Review',
                onPressed: () async {
                  await controller.loadBoard();
                  Get.to(
                    () => WeeklyReviewPage(
                      records: controller.recentRecords.toList(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.r),
            _BoardSection(
              title: 'Overview',
              height: 130.r,
              child: Row(
                children: [
                  Expanded(
                    child: _OverviewStat(
                      asset: _moods[_moodAssetIndex].$2,
                      value: controller.averageMood == null
                          ? '--'
                          : controller.averageMood!.toStringAsFixed(1),
                      label: 'Avg mood',
                    ),
                  ),
                  SizedBox(width: 8.r),
                  Expanded(
                    child: _OverviewStat(
                      asset: 'assets/images/onboarding/energy.webp',
                      value: '${controller.lowDays}',
                      label: 'Low days',
                    ),
                  ),
                  SizedBox(width: 8.r),
                  Expanded(
                    child: _OverviewStat(
                      asset: 'assets/images/onboarding/triggers.webp',
                      value: controller.topTrigger ?? '--',
                      label: 'Top trigger',
                      valueMaxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.r),
            _BoardSection(
              title: 'Mood pattern',
              height: 130.r,
              child: _MoodPattern(
                records: controller.recentRecords,
                scoreForMood: controller.moodScore,
              ),
            ),
            SizedBox(height: 12.r),
            _ComparisonSection(
              difference: controller.moodDifference,
              todayEnergy: controller.recordFor(DateTime.now())?.energy,
            ),
            SizedBox(height: 12.r),
            _ContextSection(
              contextText: controller.latestContext,
              onView: () => Get.find<MainShellController>().selectTab(3),
            ),
          ],
        ),
      ),
    );
  }

  int get _moodAssetIndex {
    final average = controller.averageMood;
    if (average == null) {
      return 2;
    }
    return controller.moodIndexForAverage(average);
  }
}

class _BoardSection extends StatelessWidget {
  const _BoardSection({
    required this.title,
    required this.height,
    required this.child,
  });

  final String title;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(16.r, 13.r, 16.r, 12.r),
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
          SizedBox(height: 10.r),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.asset,
    required this.value,
    required this.label,
    this.valueMaxLines = 1,
  });

  final String asset;
  final String value;
  final String label;
  final int valueMaxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xD8FFFFFF),
        borderRadius: BorderRadius.circular(13.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 6.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            asset,
            width: 30.r,
            height: 30.r,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(height: 2.r),
          Text(
            value,
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 2.r),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mutedDark,
              fontSize: 11,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodPattern extends StatelessWidget {
  const _MoodPattern({required this.records, required this.scoreForMood});

  final List<MoodRecord> records;
  final int Function(int) scoreForMood;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 6));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var offset = 0; offset < 7; offset++)
          Builder(
            builder: (context) {
              final date = start.add(Duration(days: offset));
              return Expanded(
                child: _MoodBar(
                  label: _weekdayLabel(date),
                  record: _recordFor(date),
                  scoreForMood: scoreForMood,
                ),
              );
            },
          ),
      ],
    );
  }

  MoodRecord? _recordFor(DateTime date) {
    final key = MoodRecord.dateKeyFor(date);
    for (final record in records) {
      if (record.dateKey == key) {
        return record;
      }
    }
    return null;
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - DateTime.monday];
  }
}

class _MoodBar extends StatelessWidget {
  const _MoodBar({
    required this.label,
    required this.record,
    required this.scoreForMood,
  });

  final String label;
  final MoodRecord? record;
  final int Function(int) scoreForMood;

  @override
  Widget build(BuildContext context) {
    final score = record == null ? 0 : scoreForMood(record!.moodIndex);
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 16.r,
              height: record == null ? 4.r : 13.r + score * 9.r,
              decoration: BoxDecoration(
                color: record == null
                    ? const Color(0x26FF658A)
                    : AppColors.accent,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 5.r),
        Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 8.5,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection({
    required this.difference,
    required this.todayEnergy,
  });

  final int? difference;
  final String? todayEnergy;

  @override
  Widget build(BuildContext context) {
    final title = switch (difference) {
      null => 'No comparison yet',
      > 0 => 'Mood is above yesterday',
      0 => 'Mood is same as yesterday',
      _ => 'Mood is below yesterday',
    };
    final detail = difference == null
        ? 'Check in for two days to compare'
        : todayEnergy == null
        ? 'Energy not logged'
        : 'Energy stayed ${todayEnergy!.toLowerCase()}';

    return Container(
      height: 86.r,
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 10.r, 12.r),
      decoration: BoxDecoration(
        color: const Color(0xB8FFF9FB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xB8FFFFFF), width: 0.7),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 7.r),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedDark,
                    fontSize: 10,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          _DifferenceBadge(difference: difference),
        ],
      ),
    );
  }
}

class _DifferenceBadge extends StatelessWidget {
  const _DifferenceBadge({required this.difference});

  final int? difference;

  @override
  Widget build(BuildContext context) {
    final isBelow = difference != null && difference! < 0;
    final isSame = difference == 0;
    final displayDifference = difference == null
        ? '—'
        : '${difference! > 0 ? '+' : ''}$difference level';
    final arrow = CustomPaint(
      size: Size.square(37.r),
      painter: _DifferenceArrowPainter(isBelow: isBelow),
    );
    final differenceText = Text(
      displayDifference,
      style: const TextStyle(
        color: AppColors.accent,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1,
        letterSpacing: 0,
      ),
    );

    return SizedBox(
      width: 76.r,
      height: 62.r,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSame || difference == null)
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x40FF658A), width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                displayDifference,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            )
          else if (isBelow) ...[
            differenceText,
            SizedBox(height: 1.r),
            arrow,
          ] else ...[
            arrow,
            SizedBox(height: 1.r),
            differenceText,
          ],
        ],
      ),
    );
  }
}

class _DifferenceArrowPainter extends CustomPainter {
  const _DifferenceArrowPainter({required this.isBelow});

  final bool isBelow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final scale = size.shortestSide / 46;
    final radius = size.shortestSide / 2 - 1.5 * scale;
    final circlePaint = Paint()
      ..color = const Color(0x40FF658A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale;
    canvas.drawCircle(center, radius, circlePaint);

    final arrowPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final direction = isBelow ? -1.0 : 1.0;
    final shaftStart = center.translate(0, direction * 8 * scale);
    final shaftEnd = center.translate(0, direction * -7 * scale);
    final headLeft = center.translate(-6.5 * scale, direction * -1 * scale);
    final headPoint = center.translate(0, direction * -7 * scale);
    final headRight = center.translate(6.5 * scale, direction * -1 * scale);

    canvas
      ..drawLine(shaftStart, shaftEnd, arrowPaint)
      ..drawLine(headLeft, headPoint, arrowPaint)
      ..drawLine(headPoint, headRight, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _DifferenceArrowPainter oldDelegate) {
    return oldDelegate.isBelow != isBelow;
  }
}

class _ContextSection extends StatelessWidget {
  const _ContextSection({required this.contextText, required this.onView});

  final String? contextText;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130.r,
      padding: EdgeInsets.fromLTRB(16.r, 13.r, 16.r, 15.r),
      decoration: BoxDecoration(
        color: const Color(0xB8FFF9FB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xB8FFFFFF), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Latest short context',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _TextAction(label: 'view', onPressed: onView),
            ],
          ),
          SizedBox(height: 10.r),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(11.r, 10.r, 11.r, 8.r),
              decoration: BoxDecoration(
                color: const Color(0x10FFFFFF),
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(color: AppColors.outline, width: 0.8),
              ),
              child: Text(
                contextText ?? 'No context yet',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.mutedDark,
                  fontSize: 10.5,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.r, vertical: 2.r),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accent,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
