import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/app_background.dart';
import '../../common/widgets/moodful_bottom_navigation_bar.dart';
import '../board/board_page.dart';
import '../check_in/check_in_page.dart';
import '../history/history_page.dart';
import '../settings/settings_page.dart';
import '../triggers/triggers_page.dart';
import 'main_shell_controller.dart';

class MainShellPage extends GetView<MainShellController> {
  const MainShellPage({super.key});

  static const _pages = [
    CheckInPage(),
    BoardPage(),
    TriggersPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => IndexedStack(
              index: controller.currentIndex.value,
              children: _pages,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => MoodfulBottomNavigationBar(
          selectedIndex: controller.currentIndex.value,
          items: MoodfulBottomNavigationBar.itemsForApp,
          onItemSelected: controller.selectTab,
        ),
      ),
    );
  }
}
