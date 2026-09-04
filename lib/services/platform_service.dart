import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/constants/app_links.dart';

class PlatformService {
  static const _lifecycleChannel = MethodChannel(
    'com.example.recordmood/lifecycle',
  );

  Future<void> moveAppToBackground() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      await SystemNavigator.pop();
      return;
    }

    try {
      await _lifecycleChannel.invokeMethod<void>('moveTaskToBack');
    } on MissingPluginException {
      // The platform channel is unavailable in Flutter widget tests.
    }
  }

  Future<void> shareApp() {
    return Share.share(
      AppLinks.downloadUrlForPlatform(defaultTargetPlatform),
      subject: 'Moodful',
    );
  }

  Future<bool> rateApp() {
    return openUrl(AppLinks.downloadUrlForPlatform(defaultTargetPlatform));
  }

  Future<bool> openPrivacyPolicy() {
    return openUrl(AppLinks.privacyPolicyUrl);
  }

  Future<bool> openTermsOfService() {
    return openUrl(AppLinks.termsOfServiceUrl);
  }

  Future<bool> openUrl(String url) {
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
