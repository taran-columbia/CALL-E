package com.example.wgj.poc_wgj

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.graphics.Rect
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity


class MyAccessibilityService : AccessibilityService() {
    private val PREFS_NAME = "FlutterSharedPreferences"

    // private var previousPackageName: String? = null
    // private var previousActivityName: String? = null

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            val currentPackageName = it.packageName?.toString()
            val currentActivityName = it.className?.toString()

            when (event.eventType) {
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                    Log.d("MyAccessibilityService", "Window State Changed $currentPackageName $currentActivityName")
                    val sharedPref = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        
                    // Read values com.whatsapp.voipcalling.VoipActivityV2
                    val isInitiatedByCallE = sharedPref.getBoolean("flutter.isInitiatedByCALLE", false)
                    val callType = sharedPref.getString("flutter.callType", null)//default null
                    val returnFromCall = sharedPref.getBoolean("flutter.returnFromCall",false)
                    Log.d("MyAccessibilityService", "Window State Changed -2 $isInitiatedByCallE $currentPackageName $currentActivityName $callType $returnFromCall")
                    if(isInitiatedByCallE==true){
                        Log.d("MyAccessibilityService", "Window State Changed -6")
                    }
                    if(currentPackageName == "com.whatsapp"){
                        Log.d("MyAccessibilityService", "Window State Changed -7")
                    }
                    if(currentActivityName == "com.whatsapp.Conversation"){
                        Log.d("MyAccessibilityService", "Window State Changed -8")
                    }
                    if (isInitiatedByCallE==true && currentPackageName == "com.whatsapp" && currentActivityName == "com.whatsapp.Conversation") {
                        // Check for the transition from chat to call
                        Log.d("MyAccessibilityService", "Window State Changed -4")
                        if (returnFromCall) {
                            Log.d("MyAccessibilityService", "Window State Changed -9")
                            handleCallTermination()
                        }
                        else if (callType == "Video call") {
                            Log.d("MyAccessibilityService", "Window State Changed -5")
                            val editor = sharedPref.edit()
                            editor.remove("callType")
                            editor.apply()
                            handleCallInitiation(it, callType)
                        }
                        else if(callType == "Voice call"){
                        }
                        
                    }
                    
                }
            }
        }
    }

    private fun handleCallInitiation(event: AccessibilityEvent?, callType: String) {
        // Logic to handle call initiation
        Log.d("MyAccessibilityService", "Call initiated in WhatsApp")
        val rootNode = rootInActiveWindow //AccessibilityNodeInfo
        rootNode?.let {
            Log.d("MyAccessibilityService", "window state changed $callType")
            findAndClickWhatsAppCallButton(it, callType)//'it' is rootNode - 'let' is shortcut 
        }

    }

    private fun handleCallTermination() {
        // Logic to handle call termination
        Log.d("MyAccessibilityService", "Window State Changed -10")

        // Redirect user to the Flutter application
        redirectToFlutterApp()
    }

    private fun redirectToFlutterApp() {
        Log.d("MyAccessibilityService", "Window State Changed -11")
        val sharedPref = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()
        editor.remove("flutter.returnFromCall")
        editor.remove("flutter.isInitiatedByCALLE")
        editor.apply()
        val redirectIntent = Intent(this, FlutterActivity::class.java)
        redirectIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(redirectIntent)
            Log.d("MyAccessibilityService", "Redirecting to Flutter App successful")
        } catch (e: Exception) {
            Log.e("MyAccessibilityService", "Failed to redirect to Flutter App", e)
        }
        Log.d("MyAccessibilityService", "Redirecting to Flutter App")
    }

    private fun findAndClickWhatsAppCallButton(node: AccessibilityNodeInfo, callType: String) {
        if (node.className == "android.widget.ImageButton" && node.contentDescription == callType) {
            // Perform the click action
            val sharedPref = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val editor = sharedPref.edit()
            editor.putBoolean("flutter.returnFromCall",true)
            editor.remove("flutter.callType")
            editor.apply()
            node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            return;
        }

        for (i in 0 until node.childCount) {
            val childNode = node.getChild(i)
            if (childNode != null) {
                findAndClickWhatsAppCallButton(childNode, callType)
            }
        }

        return;

        
    }

    override fun onInterrupt() {
        Log.d("MyAccessibilityService", "Service interrupted")
    }
}


// class MyAccessibilityService : AccessibilityService() {

//     override fun onAccessibilityEvent(event: AccessibilityEvent?) {
//         Log.d("MyAccessibilityService", "event $event")
//         if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
//             val rootNode = rootInActiveWindow //AccessibilityNodeInfo
//             rootNode?.let {
//                 Log.d("MyAccessibilityService", "window state changed $it")
//                 findAndClickVideoCallButton(it)//'it' is rootNode - 'let' is shortcut 
//             }
//         }
//     }

    

//     override fun onInterrupt() {
//         Log.d("MyAccessibilityService", "Service interrupted")
//     }
// }
