import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/app_colors.dart';
import '../constants/app_assets.dart';

class AppNavigationItem {
  const AppNavigationItem({
    required this.label,
    required this.selectedAsset,
    required this.unselectedAsset,
  });

  final String label;
  final String selectedAsset;
  final String unselectedAsset;
}

class MoodfulBottomNavigationBar extends StatelessWidget {
  const MoodfulBottomNavigationBar({
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
    super.key,
  });

  final int selectedIndex;
  final List<AppNavigationItem> items;
  final ValueChanged<int> onItemSelected;

  static const itemsForApp = [
    AppNavigationItem(
      label: 'Check',
      selectedAsset: AppAssets.checkSelected,
      unselectedAsset: AppAssets.checkUnselected,
    ),
    AppNavigationItem(
      label: 'Board',
      selectedAsset: AppAssets.boardSelected,
      unselectedAsset: AppAssets.boardUnselected,
    ),
    AppNavigationItem(
      label: 'Triggers',
      selectedAsset: AppAssets.triggersSelected,
      unselectedAsset: AppAssets.triggersUnselected,
    ),
    AppNavigationItem(
      label: 'History',
      selectedAsset: AppAssets.historySelected,
      unselectedAsset: AppAssets.historyUnselected,
    ),
    AppNavigationItem(
      label: 'Settings',
      selectedAsset: AppAssets.settingsSelected,
      unselectedAsset: AppAssets.settingsUnselected,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xF9FFF9FC),
        border: Border(top: BorderSide(color: Color(0xFFF3DDE7), width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.r,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: _NavigationButton(
                    item: items[index],
                    selected: selectedIndex == index,
                    onPressed: () => onItemSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final AppNavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final asset = selected ? item.selectedAsset : item.unselectedAsset;
    final color = selected ? AppColors.accent : AppColors.mutedDark;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onPressed,
        splashColor: const Color(0x18FF658A),
        highlightColor: const Color(0x0CFF658A),
        child: Padding(
          padding: EdgeInsets.only(top: 6.r, bottom: 4.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24.r,
                height: 24.r,
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              SizedBox(height: 3.r),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
