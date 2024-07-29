import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


class Calling extends StatefulWidget {
  const Calling({super.key});

  @override
  _CallingState createState() => _CallingState();
}

class _CallingState extends State<Calling> {
  // static const platform = MethodChannel('com.example.channel/overlay');
  static const platform =
      MethodChannel('com.example.wgj.poc_wgj/accessibility');

  @override
  void initState() {
    super.initState();
    print('Hi in flutter again');
    resetPref();
    // checkAccessibilityService(context);
  }

  Future<void> initiateCall(String callType, BuildContext context) async {
    resetPref();
    const phoneNumber = '+917597924752';
    // Set the flag indicating the call was initiated by the Flutter app
    if (callType == 'Phone call') {
      await makePhoneCall(phoneNumber);
    } else {
      final bool isEnabled = await isAccessibilityServiceEnabled(context);
       if (!isEnabled) {
        _showAccessibilityServiceDialog(context);
      }else{
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isInitiatedByCALLE', true);
        await prefs.setString('callType', callType);
        // Launch WhatsApp with the specific contact
        var url = Uri.parse('https://wa.me/$phoneNumber');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    }
  }

  void resetPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isInitiatedByCALLE');
    await prefs.remove('callType');
    await prefs.remove('returnFromCall');
  }


  Future<bool> isAccessibilityServiceEnabled(BuildContext context) async {
    final bool isEnabled = await platform.invokeMethod('isAccessibilityServiceEnabled');
    return isEnabled;
  }

  void _showAccessibilityServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accessibility Service'),
          content: const Text(
              'Accessibility Service is not enabled. Please enable it in the settings first and then try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                openAccessibilitySettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void openAccessibilitySettings() {
    platform.invokeMethod('openAccessibilitySettings');
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    var status = await Permission.phone.status;
    if (status.isGranted) {
      // Directly initiate the call using the platform channel
      dialNumber(phoneNumber);
    } else {
      if (await Permission.phone.request().isGranted) {
        // Permission granted, initiate the call
        dialNumber(phoneNumber);
      }
    }
  }

  Future<void> dialNumber(String phoneNumber) async {
    try {
      final bool result = await platform.invokeMethod('makeCall', phoneNumber);
      if (!result) {
        // Handle the case where the call initiation failed
        print('Failed to initiate call');
      }
    } on PlatformException catch (e) {
      print("Failed to make call: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WhatsApp Redirect')),
      body: Center(
          child: Column(children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            await initiateCall('Video call', context);
          },
          child: const Text('WhatsApp Video Call'),
        ),
        ElevatedButton(
          onPressed: () async {
            await initiateCall('Voice call', context);
          },
          child: const Text('WhatsApp Voice Call'),
        ),
        ElevatedButton(
          onPressed: () async {
            await initiateCall('Phone call', context);
          },
          child: const Text('Phone Call'),
        ),
      ])),
    );
  }
}
