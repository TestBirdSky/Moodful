import 'package:get/get.dart';

import '../../app/app_routes.dart';
import '../../services/local_storage_service.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._storage);

  final LocalStorageService _storage;

  Future<void> complete() async {
    await _storage.markOnboardingSeen();
    Get.offAllNamed(AppRoutes.main);
  }
}
