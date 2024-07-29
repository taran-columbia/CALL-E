// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poc_wgj/constants.dart';
import 'package:poc_wgj/database/db_helper.dart';
import 'package:poc_wgj/models/contact_model.dart';
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
                ? const Center(child: Text('No Contacts!', style: TextStyle(color: AppColors.secondaryColor, fontFamily: AppColors.fontFamily, fontSize: 24.0, fontWeight: FontWeight.bold),))
                :GridView.builder(
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
              // Navigate to a detail screen or show a dialog
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
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
                  : const Center(child: Icon(Icons.image, size: 50.0, color: Colors.grey)),
            ),
          );
        },
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'CALL-E',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: body,
      floatingActionButton: IconButton(
        onPressed: (){
          Navigator.pushNamed(context, '/contacts');
        }, 
        icon: const Icon(Icons.add),
      ),
    );
  }
}






