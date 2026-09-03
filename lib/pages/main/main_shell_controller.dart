import 'package:get/get.dart';

import '../board/board_controller.dart';
import '../check_in/check_in_controller.dart';
import '../history/history_controller.dart';
import '../triggers/triggers_controller.dart';

class MainShellController extends GetxController {
  final currentIndex = 0.obs;

  void selectTab(int index) {
    currentIndex.value = index;

    if (index == 0 && Get.isRegistered<CheckInController>()) {
      final controller = Get.find<CheckInController>();
      controller.refreshForCurrentDay();
      controller.loadTriggerOptions();
    }
    if (index == 1 && Get.isRegistered<BoardController>()) {
      Get.find<BoardController>().loadBoard();
    }
    if (index == 2 && Get.isRegistered<TriggersController>()) {
      Get.find<TriggersController>().loadTriggers();
    }
    if (index == 3 && Get.isRegistered<HistoryController>()) {
      Get.find<HistoryController>().loadRecords();
    }
  }
}
