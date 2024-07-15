package com.example.wgj.poc_wgj




import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.channel/overlay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "startOverlayService") {
                        val intent = Intent(this, MyOverlayService::class.java)
                        startService(intent)
                        result.success(null)
                    } else {
                        result.notImplemented()
                    }
                }
    }
}

