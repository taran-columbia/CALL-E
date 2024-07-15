import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.example.channel/overlay');

  @override
  void initState() {
    super.initState();
    requestOverlayPermission();
  }

  Future<void> requestOverlayPermission() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }
  }

  Future<void> startOverlayService() async {
    try {
      await platform.invokeMethod('startOverlayService');
    } on PlatformException catch (e) {
      print("Failed to start overlay service: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WhatsApp Redirect')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await requestOverlayPermission();
            await startOverlayService();

            const phoneNumber = '+917597924752';
            var url = Uri.parse('https://wa.me/$phoneNumber');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: const Text('Open WhatsApp Chat'),
        ),
      ),
    );
  }
}
