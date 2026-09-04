import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../pages/startup/startup_page.dart';
import '../services/local_storage_service.dart';
import 'app.dart';
import 'app_design.dart';
import 'app_theme.dart';

typedef StorageLoader = Future<LocalStorageService> Function();

class MoodfulBootstrapApp extends StatefulWidget {
  const MoodfulBootstrapApp({
    this.storageLoader,
    this.minimumSplashDuration = StartupPage.minimumDisplayDuration,
    super.key,
  });

  final StorageLoader? storageLoader;
  final Duration minimumSplashDuration;

  @override
  State<MoodfulBootstrapApp> createState() => _MoodfulBootstrapAppState();
}

class _MoodfulBootstrapAppState extends State<MoodfulBootstrapApp> {
  LocalStorageService? _storage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final results = await Future.wait<dynamic>([
      _loadStorage(),
      _waitMinimumSplashDurationAfterFirstFrame(),
    ]);

    if (!mounted) {
      return;
    }
    setState(() => _storage = results.first as LocalStorageService);
  }

  Future<LocalStorageService> _loadStorage() async {
    try {
      return await (widget.storageLoader?.call() ??
          LocalStorageService.create());
    } catch (_) {
      return LocalStorageService.inMemory();
    }
  }

  Future<void> _waitMinimumSplashDurationAfterFirstFrame() async {
    if (widget.minimumSplashDuration <= Duration.zero) {
      await WidgetsBinding.instance.endOfFrame;
      return;
    }

    final firstFrame = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstFrame.complete();
    });
    await firstFrame.future;
    await Future<void>.delayed(widget.minimumSplashDuration);
  }

  @override
  Widget build(BuildContext context) {
    final storage = _storage;
    if (storage != null) {
      return MoodfulApp(storage: storage);
    }

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
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mood Signals',
            theme: AppTheme.light,
            home: const StartupPage(),
          ),
        );
      },
    );
  }
}
