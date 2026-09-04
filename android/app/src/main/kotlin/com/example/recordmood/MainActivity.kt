package com.example.recordmood

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private companion object {
        const val LIFECYCLE_CHANNEL = "com.example.recordmood/lifecycle"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LIFECYCLE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method == "moveTaskToBack") {
                result.success(moveTaskToBack(true))
            } else {
                result.notImplemented()
            }
        }
    }
}
