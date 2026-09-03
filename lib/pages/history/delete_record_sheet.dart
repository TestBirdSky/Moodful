import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/app_colors.dart';

class DeleteRecordSheet extends StatelessWidget {
  const DeleteRecordSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x66000000),
      builder: (_) => const DeleteRecordSheet(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFCFD),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15.r, 9.r, 15.r, 22.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.r,
              height: 4.r,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8EA),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 15.r),
            const Text(
              'Delete record?',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 17.r),
            const Text(
              'This removes the record from\ncharts and history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedDark,
                fontSize: 12,
                height: 1.55,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 25.r),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    key: const ValueKey('cancel-delete-record-button'),
                    label: 'Cancel',
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: 19.r),
                Expanded(
                  child: _SheetButton(
                    key: const ValueKey('confirm-delete-record-button'),
                    label: 'Delete',
                    backgroundColor: const Color(0xFFFFDAD5),
                    foregroundColor: AppColors.accent,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.r,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.r),
          ),
          textStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
