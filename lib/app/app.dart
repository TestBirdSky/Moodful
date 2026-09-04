import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app_design.dart';
import 'app_routes.dart';
import 'app_theme.dart';
import '../pages/startup/startup_page.dart';
import '../services/local_storage_service.dart';

class MoodfulApp extends StatefulWidget {
  const MoodfulApp({
    required this.storage,
    this.hotStartThreshold = const Duration(seconds: 3),
    this.hotStartSplashDuration = StartupPage.minimumDisplayDuration,
    this.now,
    super.key,
  });

  final LocalStorageService storage;
  final Duration hotStartThreshold;
  final Duration hotStartSplashDuration;
  final DateTime Function()? now;

  @override
  State<MoodfulApp> createState() => _MoodfulAppState();
}

class _MoodfulAppState extends State<MoodfulApp> with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  bool _isShowingHotStartSplash = false;

  DateTime get _now => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _backgroundedAt ??= _now;
      return;
    }

    if (state != AppLifecycleState.resumed) {
      return;
    }

    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt != null &&
        _now.difference(backgroundedAt) >= widget.hotStartThreshold) {
      _showHotStartSplash();
    }
  }

  void _showHotStartSplash() {
    if (_isShowingHotStartSplash) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigator = Get.key.currentState;
      if (!mounted || navigator == null || _isShowingHotStartSplash) {
        return;
      }

      _isShowingHotStartSplash = true;
      final route = PageRouteBuilder<void>(
        settings: const RouteSettings(name: '/hot-start'),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const StartupPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
      navigator.push(route);

      await Future<void>.delayed(widget.hotStartSplashDuration);
      if (mounted && route.isActive) {
        navigator.removeRoute(route);
      }
      _isShowingHotStartSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: AppDesign.size,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Moodful',
            theme: AppTheme.light,
            initialRoute: widget.storage.hasSeenOnboarding
                ? AppRoutes.main
                : AppRoutes.onboarding,
            getPages: AppRoutes.pages,
            initialBinding: BindingsBuilder(() {
              Get.put<LocalStorageService>(widget.storage, permanent: true);
            }),
            builder: (context, appChild) {
              final mediaQuery = MediaQuery.of(context);
              final systemTextScale = mediaQuery.textScaler.scale(1);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(
                    ScreenUtil().scaleText * systemTextScale,
                  ),
                ),
                child: appChild ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
