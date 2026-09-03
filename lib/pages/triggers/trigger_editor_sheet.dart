import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/app_colors.dart';
import '../../models/custom_trigger.dart';
import 'triggers_controller.dart';

class TriggerEditorSheet extends StatefulWidget {
  const TriggerEditorSheet({required this.controller, this.trigger, super.key});

  final TriggersController controller;
  final CustomTrigger? trigger;

  static Future<void> show(
    BuildContext context, {
    required TriggersController controller,
    CustomTrigger? trigger,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x52000000),
      builder: (_) =>
          TriggerEditorSheet(controller: controller, trigger: trigger),
    );
  }

  @override
  State<TriggerEditorSheet> createState() => _TriggerEditorSheetState();
}

class _TriggerEditorSheetState extends State<TriggerEditorSheet> {
  late final TextEditingController _nameController;
  String? _errorText;
  bool _isSaving = false;

  bool get _isEditing => widget.trigger != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trigger?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: const Color(0xFFFFFCFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.r, 9.r, 16.r, 24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE8EA),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.r),
              Text(
                _isEditing ? 'Edit trigger' : 'Add trigger',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 19.r),
              const Text(
                'Trigger name',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 10.r),
              TextField(
                key: const ValueKey('trigger-name-field'),
                controller: _nameController,
                autofocus: true,
                enabled: !_isSaving,
                maxLength: 24,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _save(),
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  height: 1.3,
                  letterSpacing: 0,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Commute',
                  hintStyle: const TextStyle(
                    color: AppColors.mutedDark,
                    fontSize: 11,
                    letterSpacing: 0,
                  ),
                  errorText: _errorText,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.r,
                    vertical: 16.r,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: const BorderSide(
                      color: AppColors.outline,
                      width: 0.9,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.r),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22.r),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46.r,
                      child: FilledButton(
                        key: const ValueKey('save-trigger-button'),
                        onPressed: _isSaving ? null : _save,
                        style: FilledButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFFFA5B8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Save changes' : 'Save trigger',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 19.r),
                  Expanded(
                    child: SizedBox(
                      height: 46.r,
                      child: FilledButton(
                        key: ValueKey(
                          _isEditing
                              ? 'delete-trigger-button'
                              : 'cancel-trigger-button',
                        ),
                        onPressed: _isSaving
                            ? null
                            : _isEditing
                            ? _confirmDelete
                            : () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFFDAD5),
                          foregroundColor: AppColors.accent,
                          disabledBackgroundColor: const Color(0xFFFFE7E4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        child: Text(_isEditing ? 'Delete' : 'Cancel'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final validationMessage = widget.controller.validateName(
      _nameController.text,
      excludingId: widget.trigger?.id,
    );
    if (validationMessage != null) {
      setState(() => _errorText = validationMessage);
      return;
    }

    setState(() => _isSaving = true);
    if (_isEditing) {
      await widget.controller.editTrigger(
        widget.trigger!,
        _nameController.text,
      );
    } else {
      await widget.controller.addTrigger(_nameController.text);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete trigger?'),
        content: Text(
          '"${widget.trigger!.name}" will no longer appear in Check-in. '
          'Past records will stay unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const ValueKey('confirm-delete-trigger-button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isSaving = true);
    await widget.controller.deleteTrigger(widget.trigger!);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
