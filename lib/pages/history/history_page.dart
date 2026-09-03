import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/widgets/app_page_header.dart';
import '../../models/mood_record.dart';
import 'history_controller.dart';
import 'history_detail_page.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  static const _moods = [
    ('Great', 'assets/images/moods/mood_great.webp'),
    ('Good', 'assets/images/moods/mood_good.webp'),
    ('Okay', 'assets/images/moods/mood_okay.webp'),
    ('Low', 'assets/images/moods/mood_low.webp'),
    ('Bad', 'assets/images/moods/mood_bad.webp'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.visibleRecords;
      final groupedRecords = <String, List<MoodRecord>>{};
      for (final record in records) {
        groupedRecords.putIfAbsent(record.dateKey, () => []).add(record);
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppPageHeader(
              title: 'History',
              subtitle: 'Your check-ins over time',
            ),
            SizedBox(height: 20.r),
            _FilterBar(
              selected: controller.selectedFilter.value,
              onSelected: controller.selectFilter,
            ),
            SizedBox(height: 20.r),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent,
                onRefresh: controller.loadRecords,
                child: ListView(
                  key: const ValueKey('history-record-list'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 90.r),
                  children: [
                    if (controller.isLoading.value)
                      Padding(
                        padding: EdgeInsets.only(top: 56.r),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      )
                    else if (records.isEmpty)
                      const _EmptyHistory()
                    else
                      for (final entry in groupedRecords.entries) ...[
                        _DateHeading(dateKey: entry.key),
                        SizedBox(height: 10.r),
                        for (final record in entry.value) ...[
                          _HistoryRecordCard(
                            record: record,
                            mood:
                                _moods[record.moodIndex.clamp(
                                  0,
                                  _moods.length - 1,
                                )],
                            onTap: () =>
                                Get.to(() => HistoryDetailPage(record: record)),
                          ),
                          if (record != entry.value.last)
                            SizedBox(height: 12.r),
                        ],
                        SizedBox(height: 17.r),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final filter in HistoryController.filters) ...[
          Expanded(
            child: _FilterChip(
              label: filter,
              selected: selected == filter,
              onPressed: () => onSelected(filter),
            ),
          ),
          if (filter != HistoryController.filters.last) SizedBox(width: 7.r),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.r,
      child: Material(
        color: selected ? const Color(0xFF95627F) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18.r),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.mutedDark,
                fontSize: 12.5,
                height: 1.1,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateHeading extends StatelessWidget {
  const _DateHeading({required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDateHeading(dateKey),
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0,
      ),
    );
  }
}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({
    required this.record,
    required this.mood,
    required this.onTap,
  });

  final MoodRecord record;
  final (String, String) mood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final energy = record.energy ?? 'No energy';
    final contextText = record.context.trim();

    return Material(
      color: const Color(0xCFFFF9FB),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        key: ValueKey('history-record-${record.dateKey}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.r, 13.r, 11.r, 12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(mood.$2, width: 31.r, height: 31.r),
              SizedBox(width: 10.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$energy energy',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 7.r),
                    if (record.triggers.isNotEmpty)
                      Wrap(
                        spacing: 7.r,
                        runSpacing: 5.r,
                        children: [
                          for (final trigger in record.triggers.take(3))
                            _HistoryTriggerChip(
                              key: ValueKey(
                                'history-record-${record.dateKey}-trigger-$trigger',
                              ),
                              label: trigger,
                            ),
                        ],
                      ),
                    if (contextText.isNotEmpty) ...[
                      SizedBox(height: 7.r),
                      Text(
                        contextText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mutedDark,
                          fontSize: 12,
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.r),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedDark,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTriggerChip extends StatelessWidget {
  const _HistoryTriggerChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.r,
      constraints: BoxConstraints(minWidth: 56.r, maxWidth: 100.r),
      padding: EdgeInsets.symmetric(horizontal: 12.r),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x18FF658A),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          height: 1.1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 62.r),
      child: const Text(
        'Your check-in history will appear here.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.mutedDark,
          fontSize: 15,
          height: 1.4,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

String _formatDateHeading(String dateKey) {
  final date = DateTime.tryParse(dateKey);
  if (date == null) {
    return dateKey;
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
