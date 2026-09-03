import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../constants/app_assets.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    required this.child,
    this.asset = AppAssets.homeBackground,
    super.key,
  });

  final Widget child;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.background),
        Image.asset(
          asset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
        child,
      ],
    );
  }
}
