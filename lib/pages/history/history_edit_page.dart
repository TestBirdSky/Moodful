import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/widgets/app_background.dart';
import '../../models/custom_trigger.dart';
import '../../models/mood_record.dart';
import '../../services/local_storage_service.dart';
import '../check_in/widgets/check_in_section.dart';
import '../check_in/widgets/energy_button.dart';
import '../check_in/widgets/mood_button.dart';
import '../check_in/widgets/save_button.dart';
import '../check_in/widgets/trigger_chip.dart';
import 'delete_record_sheet.dart';
import 'history_controller.dart';

class HistoryEditPage extends StatefulWidget {
  const HistoryEditPage({required this.record, super.key});

  final MoodRecord record;

  @override
  State<HistoryEditPage> createState() => _HistoryEditPageState();
}

class _HistoryEditPageState extends State<HistoryEditPage> {
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

  late final TextEditingController _contextController;
  late int _moodIndex;
  late String? _energy;
  late final Set<String> _triggers;
  late List<String> _availableTriggers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contextController = TextEditingController(text: widget.record.context);
    _moodIndex = widget.record.moodIndex.clamp(0, _moods.length - 1);
    _energy = widget.record.energy;
    _triggers = {...widget.record.triggers};
    _availableTriggers = {...TriggerDefaults.names, ..._triggers}.toList();
    _loadCustomTriggers();
  }

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final triggerRows = (_availableTriggers.length + 2) ~/ 3;
    final triggerSectionHeight =
        50.r + triggerRows * 29.r + (triggerRows - 1).clamp(0, 20) * 7.r;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.r, 6.r, 10.r, 0),
            child: Column(
              children: [
                _EditHeader(
                  key: const ValueKey('history-edit-header'),
                  onBack: Get.back,
                ),
                SizedBox(height: 20.r),
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('history-edit-scroll'),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(bottom: 25.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CheckInSection(
                          title: 'Mood',
                          height: 132.r,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (
                                var index = 0;
                                index < _moods.length;
                                index++
                              )
                                MoodButton(
                                  label: _moods[index].$1,
                                  asset: _moods[index].$2,
                                  selected: _moodIndex == index,
                                  onPressed: () =>
                                      setState(() => _moodIndex = index),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.r),
                        CheckInSection(
                          title: 'Energy',
                          height: 124.r,
                          child: Row(
                            children: [
                              for (
                                var index = 0;
                                index < _energies.length;
                                index++
                              ) ...[
                                Expanded(
                                  child: EnergyButton(
                                    label: _energies[index].$1,
                                    asset: _energies[index].$2,
                                    selected: _energy == _energies[index].$1,
                                    onPressed: () => setState(
                                      () => _energy =
                                          _energy == _energies[index].$1
                                          ? null
                                          : _energies[index].$1,
                                    ),
                                  ),
                                ),
                                if (index != _energies.length - 1)
                                  SizedBox(width: 13.r),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 12.r),
                        CheckInSection(
                          title: 'Triggers',
                          height: triggerSectionHeight.toDouble(),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final chipWidth =
                                  (constraints.maxWidth - 14.r) / 3;
                              return Wrap(
                                spacing: 7.r,
                                runSpacing: 7.r,
                                children: [
                                  for (final trigger in _availableTriggers)
                                    TriggerChip(
                                      key: ValueKey(
                                        'history-edit-trigger-$trigger',
                                      ),
                                      label: trigger,
                                      width: chipWidth,
                                      selected: _triggers.contains(trigger),
                                      onPressed: () => setState(() {
                                        if (!_triggers.add(trigger)) {
                                          _triggers.remove(trigger);
                                        }
                                      }),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12.r),
                        CheckInSection(
                          title: 'Context',
                          height: 142.r,
                          child: TextField(
                            controller: _contextController,
                            maxLength: 120,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 11,
                              height: 1.4,
                              letterSpacing: 0,
                            ),
                            decoration: InputDecoration(
                              hintText: 'One short sentence...',
                              hintStyle: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                                letterSpacing: 0,
                              ),
                              counterText: '',
                              contentPadding: EdgeInsets.fromLTRB(
                                12.r,
                                11.r,
                                12.r,
                                8.r,
                              ),
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
                        SizedBox(height: 19.r),
                        SaveButton(
                          label: 'Save changes',
                          isSaving: _isSaving,
                          enabled: !_isSaving,
                          onPressed: _save,
                        ),
                        SizedBox(height: 14.r),
                        TextButton(
                          key: const ValueKey('edit-delete-record-button'),
                          onPressed: _isSaving ? null : _delete,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                          child: const Text('Delete record'),
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

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    final updated = MoodRecord(
      dateKey: widget.record.dateKey,
      moodIndex: _moodIndex,
      energy: _energy,
      triggers: _triggers.toList(),
      context: _contextController.text.trim(),
    );
    await Get.find<HistoryController>().saveRecord(updated);
    if (!mounted) {
      return;
    }
    Get.back(result: updated);
  }

  Future<void> _delete() async {
    final confirmed = await DeleteRecordSheet.show(context);
    if (!confirmed || !mounted) {
      return;
    }
    await Get.find<HistoryController>().deleteRecord(widget.record.dateKey);
    Get.back();
    Get.back();
  }

  Future<void> _loadCustomTriggers() async {
    final customTriggers = await Get.find<LocalStorageService>()
        .loadCustomTriggers();
    if (!mounted) {
      return;
    }
    setState(() {
      _availableTriggers = {
        ...TriggerDefaults.names,
        ...customTriggers.map((trigger) => trigger.name),
        ..._triggers,
      }.toList();
    });
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34.r,
          height: 34.r,
          child: IconButton(
            key: const ValueKey('history-edit-back-button'),
            tooltip: 'Back',
            onPressed: onBack,
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xD8FFFFFF),
              foregroundColor: AppColors.text,
            ),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ),
        ),
        SizedBox(width: 8.r),
        const Expanded(
          child: Text(
            'Edit Record',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
