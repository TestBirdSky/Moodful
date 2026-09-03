import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({required this.onPressed, this.keyValue, super.key});

  final VoidCallback onPressed;
  final String? keyValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34.r,
      height: 34.r,
      child: IconButton(
        key: keyValue == null ? null : ValueKey<String>(keyValue!),
        tooltip: 'Back',
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xD8FFFFFF),
          foregroundColor: AppColors.text,
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
      ),
    );
  }
}
