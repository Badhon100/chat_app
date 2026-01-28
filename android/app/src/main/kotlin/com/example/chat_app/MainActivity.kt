package com.example.chat_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "chat_engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "processMessage" -> {
                        val text = call.argument<String>("text") ?: ""
                        // Example native processing: trim, collapse spaces
                        val processed = text.trim().replace(Regex("\\s+"), " ")
                        result.success(mapOf("processed" to processed))
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
