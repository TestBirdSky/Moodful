import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  Future<String> getVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (_) {
      return '';
    }
  }
}
