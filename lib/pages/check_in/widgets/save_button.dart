import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_colors.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({
    required this.label,
    required this.isSaving,
    required this.enabled,
    required this.onPressed,
    this.labelFontSize = 12,
    super.key,
  });

  final String label;
  final bool isSaving;
  final bool enabled;
  final VoidCallback onPressed;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.48,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 47.r,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, Color(0xFFFFB18B)],
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0x30FF658A),
                blurRadius: 8.r,
                offset: Offset(0, 4.r),
              ),
            ],
          ),
          child: InkWell(
            onTap: enabled && !isSaving ? onPressed : null,
            borderRadius: BorderRadius.circular(24.r),
            child: Center(
              child: isSaving
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
