import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:poc_wgj/constants.dart';
import 'package:poc_wgj/models/contact_model.dart';
import 'package:poc_wgj/screens/calling.dart';
import 'package:poc_wgj/widgets/loader.dart';

class CallLogScreen extends StatefulWidget {
  final List<ContactItem> existingContacts;
  CallLogScreen({required this.existingContacts});
  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<Map<String, dynamic>> _callLogs = [];
  bool loading = false;
  List<ContactItem?> existingContacts = [];

  @override
  void initState() {
    super.initState();
    existingContacts = widget.existingContacts;
    fetchCallLogs();
  }

  Future<void> fetchCallLogs() async {
    var status = await Permission.phone.request();
    if (status.isGranted) {
      await getLogs();
    } else {
      if (await Permission.phone.request().isGranted) {
        // Permission granted, initiate the call
        // dialNumber(phoneNumber);
        await getLogs();
      }
    }
  }

  Future<void> getLogs() async {
    setState(() {
      loading = true;
    });
    final Iterable<CallLogEntry> result =
        await CallLog.query(type: CallType.missed);
    List<CallLogEntry> missedCalls = result.toList();

    missedCalls.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    List<CallLogEntry> finalCallList = missedCalls.take(5).toList();

    setState(() {
      loading = false;
      _callLogs =
          finalCallList.map((entry) => callLogEntryToMap(entry)).toList();
    });
  }

  Map<String, dynamic> callLogEntryToMap(CallLogEntry entry) {
    int index = existingContacts.indexWhere((contact) =>
        removeCountryCode(contact?.phoneNumber ?? '') ==
        removeCountryCode(entry.number ?? ''));
    bool isSavedContact = index != -1;
    return {
      'name': isSavedContact
          ? existingContacts[index]?.name
          : entry.name ?? entry.simDisplayName ?? 'Unknown caller',
      'phoneNumber': isSavedContact ? existingContacts[index]?.phoneNumber :entry.number ?? 'Unknown number',
      'timestamp': entry.timestamp,
      'formattedTime': formatTime(entry.timestamp!),
      'formattedDate': formatDate(entry.timestamp!),
      'isSavedContact': isSavedContact,
      'image': isSavedContact ? existingContacts[index]?.image : null,
      'id': isSavedContact ? existingContacts[index]?.id : null
    };
  }

//will not work in case of numbers of other countries
  String removeCountryCode(String number) {
    String phoneNumber = number.replaceAll(' ', '');
    // List of known country codes
    final countryCodes = [
      '+1',
      '+44',
      '+91',
      '+33',
      '+49'
    ]; // Add more as needed

    // Iterate over country codes and remove the match if found
    for (var code in countryCodes) {
      if (phoneNumber.startsWith(code)) {
        return phoneNumber.substring(code.length);
      }
    }

    // Return the original phone number if no country code matched
    return phoneNumber;
  }

  String formatTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat timeFormatter = DateFormat('hh:mm a');
    return timeFormatter.format(date);
  }

  String formatDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
    return dateFormatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(
        child: CustomLoader(),
      );
    } else {
      body =  _callLogs.isEmpty
            ? const Center(
                child: Text(
                'No Entry!',
                style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: AppColors.fontFamily,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              ))
            : ListView.separated(
                itemCount: _callLogs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                itemBuilder: (context, index) {
                  Map<String, dynamic> contact = _callLogs[index];
                  return ListTile(
                    leading: Icon(
                      Icons.call,
                      color:
                          contact['isSavedContact'] ? Colors.green : Colors.red,
                    ),
                    contentPadding:
                        const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                    title: Text(contact['name'] ?? 'Name Undefined'),
                    subtitle:
                        Text(contact['phoneNumber'] ?? 'Number Undefined'),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          contact['formattedTime'],
                          style: const TextStyle(color: Colors.white, fontFamily: AppColors.fontFamily, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          contact['formattedDate'],
                          style: const TextStyle(color: Colors.white, fontFamily: AppColors.fontFamily, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    onTap: contact['isSavedContact']
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Calling(
                                    contact: ContactItem(
                                        name: contact['name'],
                                        phoneNumber: contact['phoneNumber'],
                                        id: contact['id'],
                                        image: contact['image'])),
                              ),
                            );
                          }
                        : null,
                    titleTextStyle: const TextStyle(
                        fontFamily: AppColors.fontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    subtitleTextStyle: const TextStyle(
                        fontFamily: AppColors.fontFamily,
                        color: Color.fromARGB(255, 227, 149, 231)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(
                          color: AppColors.secondaryColor, width: 2),
                    ),
                  );
                },
              );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Missed Calls',
          style: TextStyle(color: Colors.white, fontFamily: AppColors.fontFamily, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: body,
      backgroundColor: AppColors.backgroundColor,
    );
  }
}
