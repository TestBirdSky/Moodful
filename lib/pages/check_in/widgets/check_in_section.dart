import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_colors.dart';

class CheckInSection extends StatelessWidget {
  const CheckInSection({
    required this.title,
    required this.height,
    required this.child,
    this.titleFontSize = 13,
    super.key,
  });

  final String title;
  final double height;
  final Widget child;
  final double titleFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(16.r, 11.r, 16.r, 12.r),
      decoration: BoxDecoration(
        color: const Color(0xB8FFF9FB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.text,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10.r),
          Expanded(child: child),
        ],
      ),
    );
  }
}
