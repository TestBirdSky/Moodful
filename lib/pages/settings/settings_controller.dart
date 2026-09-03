import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/app_info_service.dart';
import '../../services/platform_service.dart';

class SettingsController extends GetxController {
  final AppInfoService _appInfoService = AppInfoService();
  final PlatformService _platformService = PlatformService();

  final version = '...'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    version.value = await _appInfoService.getVersion();
  }

  Future<void> shareApp() async {
    try {
      await _platformService.shareApp();
    } catch (_) {
      _showActionError('Unable to open sharing');
    }
  }

  Future<void> rateApp() {
    return _openExternalAction(_platformService.rateApp);
  }

  Future<void> openPrivacyPolicy() {
    return _openExternalAction(_platformService.openPrivacyPolicy);
  }

  Future<void> openTermsOfService() {
    return _openExternalAction(_platformService.openTermsOfService);
  }

  Future<void> _openExternalAction(Future<bool> Function() action) async {
    try {
      final didLaunch = await action();
      if (!didLaunch) {
        _showActionError('Unable to open link');
      }
    } catch (_) {
      _showActionError('Unable to open link');
    }
  }

  void _showActionError(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 78),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xF9FFF9FC),
      colorText: const Color(0xFF40363A),
    );
  }
}
