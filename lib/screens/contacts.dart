import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poc_wgj/constants.dart';
import 'package:poc_wgj/models/contact_model.dart';
import 'package:poc_wgj/screens/edit_contact.dart';
import 'package:poc_wgj/widgets/loader.dart';

class Contacts extends StatefulWidget {
  final List<ContactItem> existingContacts;
  Contacts({required this.existingContacts});
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  List<ContactItem?> existingContacts = [];
  final TextEditingController _searchController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    existingContacts = widget.existingContacts;
    loadContacts();
    _searchController.addListener(_filterContacts);
  }
  

  Future<void> loadContacts() async {
    setState(() {
      loading = true;
    });
    await requestContactsPermission();
  }

  Future<void> requestContactsPermission() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      getContacts();
    } else {
      if (await Permission.contacts.request().isGranted) {
        getContacts();
      } else {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> getContacts() async {
    List<Contact> fetchedContacts = await getContactList();
    final Set<String> contactItemNumbers = existingContacts.map((item) => item?.phoneNumber ?? '').toSet();
    List<Contact> finalFetchedContacts = fetchedContacts.where((contact) => !contactItemNumbers.contains(contact.phones!.first.value)).toList();
    setState(() {
      contacts = finalFetchedContacts.isEmpty ? []: finalFetchedContacts;
      filteredContacts = finalFetchedContacts.isEmpty ? []: finalFetchedContacts;
      loading = false;
    });
  }

  void _filterContacts() {
    String query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        filteredContacts = contacts;
      });
      return;
    }

    // Check if input is numeric
    bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(query);

    setState(() {
      filteredContacts = contacts.where((contact) {
        if (isNumeric) {
          return contact.phones!.any((phone) => phone.value!.contains(query));
        } else {
          return contact.displayName != null &&
              contact.displayName!.toLowerCase().contains(query.toLowerCase());
        }
      }).toList();
    });
  }

  Future<List<Contact>> getContactList() async {
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    // Filter out contacts without a phone number
    List<Contact> filteredContacts =
        contacts.where((contact) => contact.phones!.isNotEmpty).toList();

    return filteredContacts;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(
        child: CustomLoader(),
      );
    } else {
      body = Column(
        children: <Widget>[
          Container(
            color: AppColors.backgroundColor,
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: TextField(
              controller: _searchController,
              // decoration: const InputDecoration(
              //   labelText: 'Search by name or phone number',
              //   border: OutlineInputBorder(),
              //   filled: true, // This makes the background opaque
              //   fillColor: AppColors.backgroundColor, // Set your desired background color
              // ),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: AppColors.fontFamily // Text color
              ),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
            labelText: 'Search by name or phone number',
            labelStyle: TextStyle(
              color: Colors.white,
              fontFamily: AppColors.fontFamily // Label text color
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white, // Border color when focused
                width: 2.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white, // Border color when not focused
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: Colors.transparent, // Background color
          ),
            ),
          ),
          Expanded(
            child: filteredContacts.isEmpty
                ? const Center(child: Text('No Contacts!', style: TextStyle(color: AppColors.secondaryColor, fontFamily: AppColors.fontFamily, fontSize: 24.0, fontWeight: FontWeight.bold),))
                : ListView.separated(
                    itemCount: filteredContacts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    itemBuilder: (context, index) {
                      Contact contact = filteredContacts[index];
                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.white, size: 40.0,),
                        contentPadding:
                            const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 4.0),
                        title: Text(contact.displayName ?? 'Name Undefined'),
                        subtitle: Text(contact.phones?.isNotEmpty ?? false
                            ? contact.phones!.first.value ?? 'No Number'
                            : 'No Number'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditContact(contact: ContactItem(name: contact.displayName ?? '', phoneNumber: contact.phones!.first.value ?? '',)),
                            ),
                          );
                        },
                        titleTextStyle: const TextStyle(
                            fontFamily: AppColors.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        subtitleTextStyle: const TextStyle(
                            fontFamily: AppColors.fontFamily, color: Color.fromARGB(255, 227, 149, 231)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(
                              color: AppColors.secondaryColor, width: 2),
                        ),
                      );
                    },
                  ),
          )
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contacts',
          style: TextStyle(color: Colors.white, fontFamily: AppColors.fontFamily, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: body,
      backgroundColor: AppColors.backgroundColor,
    );
  }
}
