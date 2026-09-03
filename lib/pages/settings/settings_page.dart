import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/app_colors.dart';
import '../../common/widgets/app_page_header.dart';
import '../../common/widgets/settings_item.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.r),
            child: const AppPageHeader(
              title: 'Settings',
              subtitle: 'Manage your app and related services',
            ),
          ),
          SizedBox(height: 20.r),
          SettingsItem(label: 'Rate App', onTap: controller.rateApp),
          SizedBox(height: 12.r),
          SettingsItem(label: 'Share', onTap: controller.shareApp),
          SizedBox(height: 12.r),
          SettingsItem(
            label: 'Privacy Policy',
            onTap: controller.openPrivacyPolicy,
          ),
          SizedBox(height: 12.r),
          SettingsItem(
            label: 'Terms of Service',
            onTap: controller.openTermsOfService,
          ),
          const Spacer(),
          Obx(
            () => Text(
              'Version${controller.version.value}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mutedDark,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(height: 24.r),
        ],
      ),
    );
  }
}
