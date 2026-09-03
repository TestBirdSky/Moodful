import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/constants/app_assets.dart';
import '../../common/widgets/app_background.dart';
import 'onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AppBackground(
          asset: AppAssets.onboardingBackground,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Spacer(),
                const _OnboardingCopy(),
                SizedBox(height: 29.r),
                const _OnboardingHighlights(),
                SizedBox(height: 34.r),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  child: _OnboardingButton(onPressed: controller.complete),
                ),
                SizedBox(height: 30.r),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingCopy extends StatelessWidget {
  const _OnboardingCopy();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.r),
        child: const Column(
          children: [
            Text(
              'Take a quiet moment to\nnotice how today feels.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3F3036),
                fontSize: 21,
                fontWeight: FontWeight.w700,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'A few small check-ins can help you\nsee what lifts you up, what drains\nyou, and what deserves gentler care',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF875F6F),
                fontSize: 15.5,
                fontWeight: FontWeight.w400,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHighlights extends StatelessWidget {
  const _OnboardingHighlights();

  static const _items = [
    ('Track your mood', 'assets/images/onboarding/mood.webp'),
    ('Track your energy', 'assets/images/onboarding/energy.webp'),
    ('Track your triggers', 'assets/images/onboarding/triggers.webp'),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.r),
        child: Column(
          children: [
            for (var index = 0; index < _items.length; index++) ...[
              _OnboardingHighlightRow(
                label: _items[index].$1,
                asset: _items[index].$2,
              ),
              if (index != _items.length - 1) SizedBox(height: 10.r),
            ],
          ],
        ),
      ),
    );
  }
}

class _OnboardingHighlightRow extends StatelessWidget {
  const _OnboardingHighlightRow({required this.label, required this.asset});

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.r,
      padding: EdgeInsets.symmetric(horizontal: 44.r),
      decoration: BoxDecoration(
        color: const Color(0x35FFFFFF),
        border: Border.all(color: const Color(0xE8FFFFFF)),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: [
          Image.asset(
            asset,
            width: 34.r,
            height: 34.r,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(width: 9.r),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF875F6F),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  const _OnboardingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "Begin today's check-in",
      child: SizedBox(
        height: 55.r,
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.onboardingButton),
                fit: BoxFit.fill,
              ),
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(28.r),
              splashColor: const Color(0x24FFFFFF),
              highlightColor: const Color(0x18FFFFFF),
              child: const Center(
                child: Text(
                  "Begin today's check-in",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
