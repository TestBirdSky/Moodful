import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/app_colors.dart';
import '../../common/constants/app_assets.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  static const minimumDisplayDuration = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final barWidth = math.min(screenSize.width * 0.64, 240.r);
    final bottom = MediaQuery.paddingOf(context).bottom + 54.r;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppAssets.splashBackground,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            Positioned(
              left: (screenSize.width - barWidth) / 2,
              bottom: bottom,
              width: barWidth,
              height: 8.r,
              child: const _StartupProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupProgressIndicator extends StatefulWidget {
  const _StartupProgressIndicator();

  @override
  State<_StartupProgressIndicator> createState() =>
      _StartupProgressIndicatorState();
}

class _StartupProgressIndicatorState extends State<_StartupProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(999.r);

    return SizedBox(
      key: const ValueKey('startup-progress-indicator'),
      height: 8.r,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB8FFFFFF),
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final trackWidth = constraints.maxWidth;
                  final fillWidth = trackWidth * 0.42;
                  final left =
                      trackWidth * (-0.30 + (_controller.value * 1.18));

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        left: left,
                        top: 0,
                        bottom: 0,
                        width: fillWidth,
                        child: child!,
                      ),
                    ],
                  );
                },
                child: DecoratedBox(
                  key: const ValueKey('startup-progress-fill'),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF58BB2),
                    borderRadius: borderRadius,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
