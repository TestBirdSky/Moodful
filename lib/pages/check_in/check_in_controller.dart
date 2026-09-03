import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../board/board_controller.dart';
import '../../models/custom_trigger.dart';
import '../../models/mood_record.dart';
import '../../services/local_storage_service.dart';
import '../main/main_shell_controller.dart';

class CheckInController extends GetxController with WidgetsBindingObserver {
  CheckInController(
    this._storage, {
    DateTime Function()? now,
    this.saveTimeout = const Duration(seconds: 3),
  }) : _now = now ?? DateTime.now;

  final LocalStorageService _storage;
  final DateTime Function() _now;
  final Duration saveTimeout;
  final TextEditingController contextController = TextEditingController();
  final selectedMoodIndex = RxnInt(2);
  final selectedEnergy = RxnString('High');
  final selectedTriggers = <String>{}.obs;
  final availableTriggers = <String>[...TriggerDefaults.names].obs;
  final hasTodayRecord = false.obs;
  final isSaving = false.obs;

  Timer? _dayChangeTimer;
  String? _loadedDateKey;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadTriggerOptions();
    loadTodayRecord();
  }

  @override
  void onClose() {
    _dayChangeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    contextController.dispose();
    super.onClose();
  }

  Future<void> loadTodayRecord() async {
    final now = _now();
    _loadedDateKey = MoodRecord.dateKeyFor(now);
    hasTodayRecord.value = false;
    selectedMoodIndex.value = 2;
    selectedEnergy.value = 'High';
    selectedTriggers.clear();
    contextController.clear();

    final record = await _storage.loadTodayRecord(onDate: now);
    if (record == null) {
      _scheduleDayChangeCheck();
      return;
    }

    hasTodayRecord.value = true;
    selectedMoodIndex.value = record.moodIndex;
    selectedEnergy.value = record.energy;
    selectedTriggers.assignAll(record.triggers);
    contextController.text = record.context;
    _scheduleDayChangeCheck();
  }

  Future<void> refreshForCurrentDay() async {
    final currentDateKey = MoodRecord.dateKeyFor(_now());
    if (_loadedDateKey == currentDateKey) {
      _scheduleDayChangeCheck();
      return;
    }
    await loadTodayRecord();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshForCurrentDay();
    }
  }

  void _scheduleDayChangeCheck() {
    _dayChangeTimer?.cancel();
    final now = _now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _dayChangeTimer = Timer(
      tomorrow.difference(now) + const Duration(milliseconds: 100),
      refreshForCurrentDay,
    );
  }

  Future<void> loadTriggerOptions() async {
    final customTriggers = await _storage.loadCustomTriggers();
    availableTriggers.assignAll([
      ...TriggerDefaults.names,
      ...customTriggers.map((item) => item.name),
    ]);
  }

  void selectMood(int index) {
    selectedMoodIndex.value = index;
  }

  void toggleEnergy(String energy) {
    selectedEnergy.value = selectedEnergy.value == energy ? null : energy;
  }

  void toggleTrigger(String trigger) {
    if (!selectedTriggers.add(trigger)) {
      selectedTriggers.remove(trigger);
    }
  }

  Future<void> saveCheckIn() async {
    final moodIndex = selectedMoodIndex.value;
    if (moodIndex == null || isSaving.value) {
      _showMessage('Please select a mood.');
      return;
    }

    final wasUpdate = hasTodayRecord.value;
    isSaving.value = true;
    try {
      await _storage
          .saveTodayRecord(
            MoodRecord(
              dateKey: MoodRecord.dateKeyFor(_now()),
              moodIndex: moodIndex,
              energy: selectedEnergy.value,
              triggers: selectedTriggers.toList(),
              context: contextController.text.trim(),
            ),
          )
          .timeout(saveTimeout);
      hasTodayRecord.value = true;
    } catch (error, stackTrace) {
      debugPrint('Unable to save check-in: $error\n$stackTrace');
      _showMessage('Unable to save check-in. Please try again.');
      return;
    } finally {
      isSaving.value = false;
    }

    if (!wasUpdate) {
      Get.find<MainShellController>().selectTab(1);
      return;
    }

    if (Get.isRegistered<BoardController>()) {
      unawaited(_refreshBoard());
    }
    _showMessage("Today's check-in updated.");
  }

  Future<void> _refreshBoard() async {
    try {
      await Get.find<BoardController>().loadBoard();
    } catch (error, stackTrace) {
      debugPrint('Unable to refresh Mood Board: $error\n$stackTrace');
    }
  }

  void _showMessage(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 78),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xF9FFF9FC),
      colorText: const Color(0xFF40363A),
    );
  }
}
