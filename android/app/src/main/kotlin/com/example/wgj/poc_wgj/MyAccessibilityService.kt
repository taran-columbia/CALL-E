package com.example.wgj.poc_wgj


import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log

class MyAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
    Log.d("AccessibilityService", "WGJ-3")
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val rootNode = rootInActiveWindow
            rootNode?.let {
                findAndLogVideoCallButton(it)
            }
        }
    }

    private fun findAndLogVideoCallButton(node: AccessibilityNodeInfo) {
    
        if (node.className == "android.widget.ImageButton" && node.contentDescription == "Video call") {
            val bounds = android.graphics.Rect()
            node.getBoundsInScreen(bounds)
            val x = bounds.centerX()
            val y = bounds.centerY()
            // Log the coordinates
            Log.d("AccessibilityService", "Video call button coordinates: x=$x, y=$y")
            // Save coordinates in SharedPreferences
            val sharedPref = getSharedPreferences("MyPrefs", Context.MODE_PRIVATE)
            with(sharedPref.edit()) {
                putInt("x_coord", x)
                putInt("y_coord", y)
                apply()
            }
        }

        for (i in 0 until node.childCount) {
            findAndLogVideoCallButton(node.getChild(i))
        }
    }

    override fun onInterrupt() {
        // Handle interruptions
    }
}
