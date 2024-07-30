// import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poc_wgj/constants.dart';
import 'package:poc_wgj/models/contact_model.dart';
import 'package:poc_wgj/screens/edit_contact.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


class Calling extends StatefulWidget {
  final ContactItem? contact;
  const Calling({this.contact});

  @override
  _CallingState createState() => _CallingState();
}

class _CallingState extends State<Calling> {
  // static const platform = MethodChannel('com.example.channel/overlay');
  static const platform = MethodChannel('com.example.wgj.poc_wgj/accessibility');
  String? name = '';
  Uint8List? image;
  String? phoneNumber = '';
  int? id;

  @override
  void initState() {
    super.initState();
    name = widget.contact?.name ;
    image = widget.contact?.image;
    phoneNumber = widget.contact?.phoneNumber;
    id = widget.contact?.id;
    print('Hi in flutter again');
    resetPref();
    // checkAccessibilityService(context);
  }

  Future<void> initiateCall(String callType, BuildContext context) async {
    resetPref();
    // const phoneNumber = '+917597924752';
    // Set the flag indicating the call was initiated by the Flutter app
    if(phoneNumber!=null || phoneNumber!=''){
      if (callType == 'Phone call') {
      await makePhoneCall(phoneNumber!);
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(name ?? 'No Name', style: const TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditContact(contact: ContactItem(name: name!, phoneNumber: phoneNumber!, id: id, image: image)),
                ),
              );
        
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
          children: <Widget>[
            image != null
                ? ClipOval(
                    child: Image.memory(
                      image!,
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipOval(
                    child: Container(
                      width: 200.0,
                      height: 200.0,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 50),
                    ),
                  ),
            const SizedBox(height: 20.0,),
            Text(name??'No Name', style: const TextStyle(color: AppColors.secondaryColor, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 30.0),),
            const SizedBox(height: 10.0,),
            Text(phoneNumber??'No Phone Number', style: const TextStyle(color: AppColors.secondaryColor, fontFamily: 'Poppins', fontSize: 20.0),),
            const SizedBox(height: 20.0,),
            
                ElevatedButton(
                  onPressed: () async {
                    await initiateCall('Video call', context);
                  },
                  child: const Text('Video Call'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await initiateCall('Voice call', context);
                  },
                  child: const Text('Voice Call'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await initiateCall('Phone call', context);
                  },
                  child: const Text('Phone Call'),
                ),
              ],
            ),
        )
      ),
    );
  }
}
