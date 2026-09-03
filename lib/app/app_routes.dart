import 'package:get/get.dart';

import '../pages/main/main_shell_controller.dart';
import '../pages/main/main_shell_page.dart';
import '../pages/onboarding/onboarding_controller.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/board/board_controller.dart';
import '../pages/check_in/check_in_controller.dart';
import '../pages/history/history_controller.dart';
import '../pages/settings/settings_controller.dart';
import '../pages/triggers/triggers_controller.dart';
import '../services/local_storage_service.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const main = '/main';

  static List<GetPage<dynamic>> get pages {
    return [
      GetPage(
        name: onboarding,
        page: OnboardingPage.new,
        binding: BindingsBuilder(() {
          Get.lazyPut<OnboardingController>(
            () => OnboardingController(Get.find<LocalStorageService>()),
          );
        }),
      ),
      GetPage(
        name: main,
        page: MainShellPage.new,
        binding: BindingsBuilder(() {
          Get.put(MainShellController());
          Get.lazyPut<CheckInController>(
            () => CheckInController(Get.find<LocalStorageService>()),
          );
          Get.lazyPut<BoardController>(
            () => BoardController(Get.find<LocalStorageService>()),
          );
          Get.lazyPut<TriggersController>(
            () => TriggersController(Get.find<LocalStorageService>()),
          );
          Get.lazyPut<HistoryController>(
            () => HistoryController(Get.find<LocalStorageService>()),
          );
          Get.lazyPut<SettingsController>(SettingsController.new);
        }),
      ),
    ];
  }
}
