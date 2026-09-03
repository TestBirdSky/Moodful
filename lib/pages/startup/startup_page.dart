import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/app_colors.dart';
import '../../common/constants/app_assets.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  static const minimumDisplayDuration = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) {
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
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 54.r),
                  child: FractionallySizedBox(
                    widthFactor: 0.64,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 240.r),
                      child: const _StartupProgressIndicator(),
                    ),
                  ),
                ),
              ),
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
    return SizedBox(
      key: const ValueKey('startup-progress-indicator'),
      height: 8.r,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xB8FFFFFF)),
            Positioned.fill(
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
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
