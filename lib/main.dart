import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // static const platform = MethodChannel('com.example.channel/overlay');
  static const platform =
      MethodChannel('com.example.wgj.poc_wgj/accessibility');

  @override
  void initState() {
    super.initState();
    print('Hi in flutter again');
    resetPref();
    // checkAccessibilityService(context);
    isAccessibilityServiceEnabled(context);
  }

  
  void resetPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isInitiatedByCALLE');
    await prefs.remove('callType');
    await prefs.remove('returnFromCall');
  }

  // Future<void> checkAccessibilityService(BuildContext context) async {
  //   var status = await Permission.accessNotificationPolicy.status;

  //   if (!status.isGranted) {
  //     _showAccessibilityServiceDialog(context);
  //   } else {
  //     // Accessibility service is enabled, proceed with your logic
  //     print('Accessibility Service is enabled.');
  //   }
  // }

  Future<void> isAccessibilityServiceEnabled(BuildContext context) async {
    final bool isEnabled =
        await platform.invokeMethod('isAccessibilityServiceEnabled');
    // return isEnabled;
    if (!isEnabled) {
      _showAccessibilityServiceDialog(context);
    } else {
      // Accessibility service is enabled, proceed with your logic
      print('Accessibility Service is enabled.');
    }
  }

  void _showAccessibilityServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accessibility Service'),
          content: const Text(
              'Accessibility Service is not enabled. Please enable it in the settings and try again.'),
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

  Future<void> initiateCall(String callType) async {
    // Set the flag indicating the call was initiated by the Flutter app
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final bool isEnabled = await platform.invokeMethod('isAccessibilityServiceEnabled');
    // if(isEnabled){
    //   print('This should print');
    // }
    // await prefs.remove('isInitiatedByCALLE');
    // await prefs.remove('callType');
    // await prefs.remove('returnFromCall');

    print("Window State Changed-3 $callType");
    await prefs.setBool('isInitiatedByCALLE', true);
    // await prefs.setBool('isInitiatedByCALLEE', true);
    await prefs.setString('callType', callType);

    // Launch WhatsApp with the specific contact
    const phoneNumber = '+917597924752';
    var url = Uri.parse('https://wa.me/$phoneNumber');
    if (callType == 'Phone call') {
      // url = Uri.parse('tel:$phoneNumber');
      await makePhoneCall(phoneNumber);
    }
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
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
            await initiateCall('Video call');
          },
          child: const Text('WhatsApp Video Call'),
        ),
        ElevatedButton(
          onPressed: () async {
            await initiateCall('Voice call');
          },
          child: const Text('WhatsApp Voice Call'),
        ),
        ElevatedButton(
          onPressed: () async {
            await initiateCall('Phone call');
          },
          child: const Text('Phone Call'),
        ),
      ])),
    );
  }
}
