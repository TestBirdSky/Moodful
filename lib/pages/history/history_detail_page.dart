import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/widgets/app_background.dart';
import '../../common/widgets/app_back_button.dart';
import '../../models/mood_record.dart';
import '../check_in/widgets/check_in_section.dart';
import 'delete_record_sheet.dart';
import 'history_controller.dart';
import 'history_edit_page.dart';

class HistoryDetailPage extends StatefulWidget {
  const HistoryDetailPage({required this.record, super.key});

  final MoodRecord record;

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  late MoodRecord _record;

  static const _moods = [
    ('Great', 'assets/images/moods/mood_great.webp'),
    ('Good', 'assets/images/moods/mood_good.webp'),
    ('Okay', 'assets/images/moods/mood_okay.webp'),
    ('Low', 'assets/images/moods/mood_low.webp'),
    ('Bad', 'assets/images/moods/mood_bad.webp'),
  ];

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  @override
  Widget build(BuildContext context) {
    final mood = _moods[_record.moodIndex.clamp(0, _moods.length - 1)];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(11.r, 6.r, 11.r, 0),
            child: Column(
              children: [
                _DetailHeader(
                  key: const ValueKey('history-detail-header'),
                  title: 'Record Detail',
                  actionLabel: 'Edit',
                  onBack: Get.back,
                  onAction: _edit,
                ),
                SizedBox(height: 27.r),
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('history-detail-scroll'),
                    padding: EdgeInsets.only(bottom: 26.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _formatDate(_record.dateKey, includeYear: true),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 12.r),
                        _RecordSummary(record: _record, mood: mood),
                        SizedBox(height: 13.r),
                        CheckInSection(
                          title: 'Triggers map',
                          height: 95.r,
                          child: _TriggerWrap(triggers: _record.triggers),
                        ),
                        SizedBox(height: 13.r),
                        CheckInSection(
                          title: 'Context',
                          height: 142.r,
                          child: _ContextBox(
                            text: _record.context.trim().isEmpty
                                ? 'No context added.'
                                : _record.context.trim(),
                          ),
                        ),
                        SizedBox(height: 104.r),
                        SizedBox(
                          height: 47.r,
                          child: FilledButton(
                            key: const ValueKey('delete-record-button'),
                            onPressed: _delete,
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
                            child: const Text('Delete record'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _edit() async {
    final updated = await Get.to<MoodRecord>(
      () => HistoryEditPage(record: _record),
    );
    if (updated != null && mounted) {
      setState(() => _record = updated);
    }
  }

  Future<void> _delete() async {
    final confirmed = await DeleteRecordSheet.show(context);
    if (!confirmed || !mounted) {
      return;
    }
    await Get.find<HistoryController>().deleteRecord(_record.dateKey);
    Get.back();
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.title,
    required this.actionLabel,
    required this.onBack,
    required this.onAction,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onBack;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Back',
          child: AppBackButton(
            keyValue: 'history-detail-back-button',
            onPressed: onBack,
          ),
        ),
        SizedBox(width: 8.r),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            padding: EdgeInsets.symmetric(horizontal: 2.r),
            minimumSize: Size(32.r, 34.r),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              letterSpacing: 0,
            ),
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _RecordSummary extends StatelessWidget {
  const _RecordSummary({required this.record, required this.mood});

  final MoodRecord record;
  final (String, String) mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67.r,
      padding: EdgeInsets.symmetric(horizontal: 13.r),
      decoration: BoxDecoration(
        color: const Color(0xCFFFF9FB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Image.asset(mood.$2, width: 31.r, height: 31.r),
          SizedBox(width: 10.r),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${record.energy ?? 'No'} energy',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 5.r),
              const Text(
                'Saved for this day',
                style: TextStyle(
                  color: AppColors.mutedDark,
                  fontSize: 10,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TriggerWrap extends StatelessWidget {
  const _TriggerWrap({required this.triggers});

  final List<String> triggers;

  @override
  Widget build(BuildContext context) {
    if (triggers.isEmpty) {
      return const Text(
        'No triggers added.',
        style: TextStyle(
          color: AppColors.mutedDark,
          fontSize: 11,
          letterSpacing: 0,
        ),
      );
    }
    return Wrap(
      spacing: 7.r,
      runSpacing: 7.r,
      children: [
        for (final trigger in triggers) _DetailTriggerChip(label: trigger),
      ],
    );
  }
}

class _DetailTriggerChip extends StatelessWidget {
  const _DetailTriggerChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.r,
      constraints: BoxConstraints(minWidth: 73.r, maxWidth: 110.r),
      padding: EdgeInsets.symmetric(horizontal: 14.r),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x18FF658A),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ContextBox extends StatelessWidget {
  const _ContextBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x10FFFFFF),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: AppColors.outline, width: 0.8),
      ),
      padding: EdgeInsets.fromLTRB(12.r, 11.r, 12.r, 8.r),
      child: Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.mutedDark,
          fontSize: 11,
          height: 1.4,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

String _formatDate(String dateKey, {required bool includeYear}) {
  final date = DateTime.tryParse(dateKey);
  if (date == null) {
    return dateKey;
  }
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final formatted = '${months[date.month - 1].substring(0, 3)} ${date.day}';
  return includeYear ? '$formatted, ${date.year}' : formatted;
}
