import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_colors.dart';

class MoodButton extends StatelessWidget {
  const MoodButton({
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
      child: InkResponse(
        onTap: onPressed,
        radius: 32.r,
        splashColor: AppColors.accent.withValues(alpha: 0.15),
        child: SizedBox(
          width: 45.r,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 45.r,
                height: 45.r,
                padding: selected ? EdgeInsets.all(1.5.r) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: AppColors.accent, width: 1.6.r)
                      : null,
                ),
                child: Image.asset(asset, fit: BoxFit.contain),
              ),
              SizedBox(height: 5.r),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected ? AppColors.accent : AppColors.text,
                      fontSize: labelFontSize,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
