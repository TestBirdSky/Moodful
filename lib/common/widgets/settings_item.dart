import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/app_colors.dart';
import '../constants/app_assets.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    required this.label,
    required this.onTap,
    this.detail,
    super.key,
  });

  final String label;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF8FA),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        splashColor: const Color(0x14FF658A),
        highlightColor: const Color(0x0AFF658A),
        child: SizedBox(
          height: 58.r,
          child: Padding(
            padding: EdgeInsets.only(left: 18.r, right: 14.r),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF3C3034),
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                if (detail != null)
                  Padding(
                    padding: EdgeInsets.only(right: 7.r),
                    child: Text(
                      detail!,
                      style: const TextStyle(
                        color: AppColors.mutedDark,
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: Image.asset(
                    AppAssets.settingsArrow,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
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
