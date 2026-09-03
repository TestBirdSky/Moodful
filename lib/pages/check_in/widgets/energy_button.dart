import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_colors.dart';

class EnergyButton extends StatelessWidget {
  const EnergyButton({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onPressed,
    this.labelFontSize = 11,
    super.key,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onPressed;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 64.r,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0x12FF658A)
                  : const Color(0x08FFFFFF),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.outline,
                width: selected ? 1 : 0.8,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  asset,
                  width: 22.r,
                  height: 22.r,
                  color: selected
                      ? const Color(0xFFFD788F)
                      : const Color(0xFFAF959D),
                  colorBlendMode: BlendMode.srcIn,
                ),
                SizedBox(height: 4.r),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.accent : AppColors.text,
                    fontSize: labelFontSize,
                    height: 1.15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
