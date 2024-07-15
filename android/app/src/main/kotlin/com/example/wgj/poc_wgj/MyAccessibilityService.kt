package com.example.wgj.poc_wgj

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.graphics.Rect
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class MyAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val rootNode = rootInActiveWindow
            rootNode?.let {
                findAndClickVideoCallButton(it)
            }
        }
    }

    private fun findAndClickVideoCallButton(node: AccessibilityNodeInfo) {
        if (node.className == "android.widget.ImageButton" && node.contentDescription == "Video call") {
            // Perform the click action
            node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            Log.d("MyAccessibilityService", "Clicked on the Video call button")

            // Log the coordinates for debugging
            val bounds = Rect()
            node.getBoundsInScreen(bounds)
            val x = bounds.centerX()
            val y = bounds.centerY()
            Log.d("MyAccessibilityService", "Video call button coordinates: x=$x, y=$y")

            // Save coordinates in SharedPreferences for debugging or further use
            val sharedPref = getSharedPreferences("MyPrefs", Context.MODE_PRIVATE)
            with(sharedPref.edit()) {
                putInt("x_coord", x)
                putInt("y_coord", y)
                apply()
            }
        }

        for (i in 0 until node.childCount) {
            findAndClickVideoCallButton(node.getChild(i))
        }
    }

    override fun onInterrupt() {
        Log.d("MyAccessibilityService", "Service interrupted")
    }
}
