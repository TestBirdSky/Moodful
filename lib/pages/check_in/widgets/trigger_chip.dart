import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_colors.dart';

class TriggerChip extends StatelessWidget {
  const TriggerChip({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.labelFontSize = 11,
    this.width,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final double labelFontSize;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: width ?? 71.r,
          height: 29.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0x18FF658A) : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: selected
                ? Border.all(color: AppColors.accent, width: 0.8)
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.accent : AppColors.mutedDark,
              fontSize: labelFontSize,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
