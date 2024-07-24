package com.example.wgj.poc_wgj




import android.content.Intent
// import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.wgj.poc_wgj/accessibility"

    // override fun onCreate(savedInstanceState: Bundle?) {
    //     super.onCreate(savedInstanceState)
    //     // Inflate UI or perform any additional setup here
    //     inflateUI()
    // }

    // private fun inflateUI() {
    //     // Perform UI inflation or any setup needed for your activity
    //     // This is where you can set up the layout or other UI components
    //     setContentView(R.layout.activity_main)
    // }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "openAccessibilitySettings") {
                        openAccessibilitySettings()
                        result.success(null)
                    } else {
                        Log.d("MainActivity", "Window State Changed -12")
                        result.notImplemented()
                    }
                }
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}

