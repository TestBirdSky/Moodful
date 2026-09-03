import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/widgets/app_background.dart';
import '../../models/custom_trigger.dart';
import 'trigger_editor_sheet.dart';
import 'triggers_controller.dart';

class AllTriggersPage extends GetView<TriggersController> {
  const AllTriggersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Obx(
            () => Padding(
              padding: EdgeInsets.fromLTRB(14.r, 6.r, 14.r, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PageHeader(
                    key: const ValueKey('all-triggers-header'),
                    onBack: Get.back,
                  ),
                  SizedBox(height: 21.r),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          key: const ValueKey('all-triggers-list'),
                          padding: EdgeInsets.only(bottom: 92.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _TriggerListSection(
                                title: 'Default triggers',
                                children: [
                                  for (final name in TriggerDefaults.names)
                                    _TriggerListItem(
                                      title: name,
                                      subtitle: 'Default',
                                      actionLabel: 'Locked',
                                    ),
                                ],
                              ),
                              SizedBox(height: 12.r),
                              _TriggerListSection(
                                title: 'Custom triggers',
                                emptyLabel: 'No custom triggers yet',
                                children: [
                                  for (final trigger
                                      in controller.customTriggers)
                                    _TriggerListItem(
                                      title: trigger.name,
                                      subtitle: _usageLabel(
                                        controller.usageCount(trigger),
                                      ),
                                      actionLabel: 'Edit',
                                      actionKey: ValueKey(
                                        'edit-trigger-${trigger.id}',
                                      ),
                                      onAction: () => TriggerEditorSheet.show(
                                        context,
                                        controller: controller,
                                        trigger: trigger,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 16.r,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x28C47B8D),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 5.r),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 47.r,
                              child: FilledButton(
                                key: const ValueKey(
                                  'add-custom-trigger-button',
                                ),
                                onPressed: () => TriggerEditorSheet.show(
                                  context,
                                  controller: controller,
                                ),
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
                                child: const Text('+ Add custom trigger'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _usageLabel(int count) {
    if (count == 0) {
      return 'Never used';
    }
    return 'Used $count ${count == 1 ? 'time' : 'times'}';
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34.r,
          height: 34.r,
          child: IconButton(
            key: const ValueKey('all-triggers-back-button'),
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
        const Text(
          'All Triggers',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _TriggerListSection extends StatelessWidget {
  const _TriggerListSection({
    required this.title,
    required this.children,
    this.emptyLabel,
  });

  final String title;
  final List<Widget> children;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 13.r, 16.r, 16.r),
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 12.r),
          if (children.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.r),
              child: Text(
                emptyLabel ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10.5,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
            )
          else
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) SizedBox(height: 10.r),
            ],
        ],
      ),
    );
  }
}

class _TriggerListItem extends StatelessWidget {
  const _TriggerListItem({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.actionKey,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final Key? actionKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.r,
      padding: EdgeInsets.fromLTRB(12.r, 6.r, 8.r, 6.r),
      decoration: BoxDecoration(
        color: const Color(0xD8FFFFFF),
        borderRadius: BorderRadius.circular(13.r),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedDark,
                    fontSize: 9,
                    height: 1.15,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          if (onAction == null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.r),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.mutedDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            )
          else
            TextButton(
              key: actionKey,
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                minimumSize: Size(48.r, 38.r),
                padding: EdgeInsets.symmetric(horizontal: 8.r),
                textStyle: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}
