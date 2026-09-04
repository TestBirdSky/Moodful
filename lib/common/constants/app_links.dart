import 'package:flutter/foundation.dart';

final class AppLinks {
  const AppLinks._();

  // TODO(iOS release): Replace all placeholder URLs with the production
  // App Store, privacy policy, and terms links before TestFlight upload.
  static const String androidDownloadUrl =
      'https://play.google.com/store/apps/details?id=com.example.recordmood';
  static const String iosDownloadUrl =
      'https://apps.apple.com/app/id0000000000';
  static const String privacyPolicyUrl =
      'https://example.com/moodful/privacy-policy';
  static const String termsOfServiceUrl =
      'https://example.com/moodful/terms-of-service';

  static String downloadUrlForPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.iOS ? iosDownloadUrl : androidDownloadUrl;
  }
}
