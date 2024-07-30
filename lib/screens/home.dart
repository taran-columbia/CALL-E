// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poc_wgj/constants.dart';
import 'package:poc_wgj/database/db_helper.dart';
import 'package:poc_wgj/models/contact_model.dart';
import 'package:poc_wgj/screens/calling.dart';
import 'package:poc_wgj/screens/contacts.dart';
import 'package:poc_wgj/widgets/loader.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ContactItem> _contactList = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    getContactList();
  }

  Future<void> getContactList() async {
    List<ContactItem> list = await DBHelper().getContacts();
    setState(() {
      _contactList = list;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(
        child: CustomLoader(),
      );
    } else {
      body = _contactList.isEmpty
          ? const Center(
              child: Text(
              'No Contacts!',
              style: TextStyle(
                  color: AppColors.secondaryColor,
                  fontFamily: AppColors.fontFamily,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns per row
                crossAxisSpacing: 8.0, // Space between columns
                mainAxisSpacing: 8.0, // Space between rows
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: _contactList.length,
              itemBuilder: (context, index) {
                final contact = _contactList[index];
                return GestureDetector(
                  onTap: () {
                    // Handle the tap event
                    print('Tapped on ${contact.name}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Calling(
                            contact: ContactItem(
                                name: contact.name,
                                phoneNumber: contact.phoneNumber,
                                id: contact.id,
                                image: contact.image)),
                      ),
                    );
                    // Navigate to a detail screen or show a dialog
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      // border: Border.all(color: Color.fromARGB(255, 24, 229, 13)),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 243, 235, 244)
                              .withOpacity(0.3), // Shadow color
                          spreadRadius: 2, // How much the shadow spreads
                          blurRadius: 10, // The blur effect of the shadow
                          offset:
                              const Offset(0, 5), // The offset of the shadow
                        ),
                      ],
                    ),
                    child: contact.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.memory(
                              contact.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.image_not_supported_outlined,
                                  size: 50.0, color: AppColors.secondaryColor),
                              Text(
                                contact.name,
                                style: const TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )),
                  ),
                );
              },
            );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: const Icon(Icons.phone),
        title: const Text(
          'CALL-E',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Contacts(
                          existingContacts: _contactList,
                        )),
              );
            },
          ),
        ],
      ),
      body: body,
      // floatingActionButton: IconButton(
      //   onPressed: (){
      //     Navigator.pushNamed(context, '/contacts');
      //   },
      //   icon: const Icon(Icons.add),
      // ),
    );
  }
}
