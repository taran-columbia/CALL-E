import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:contacts_service/contacts_service.dart';
import 'package:poc_wgj/constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:poc_wgj/database/db_helper.dart';
import 'package:poc_wgj/models/contact_model.dart';
import 'package:poc_wgj/routes/app_routes.dart';

Future<Uint8List?> getImageBytes(File? imageFile) async {
  if(imageFile == null || !await imageFile.exists()){
    return null;
  }
    return await imageFile.readAsBytes();
}


class EditContact extends StatefulWidget {
   final String name;
   final String phoneNumber;

  EditContact({required this.name, required this.phoneNumber});

  @override
  _EditContactState createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  TextEditingController _nameController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    

    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );
      

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    }
    } catch (e) {
      print('Error pick image wgj $e');
    }
  }

  // void _saveContact() {
  //   // Update the contact's name
  //   widget.contact.displayName = _nameController.text;
  //   // Save the updated contact
  //   // ContactsService.updateContact(widget.contact);
  //   Navigator.pop(context); // Go back to the previous screen
  // }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Contact Details', style: TextStyle(color: Colors.white),),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.save),
        //     onPressed: _saveContact,
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _imageFile != null
                ? ClipOval(
                    child: Image.file(
                      _imageFile!,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20.0,),
            TextField(
              controller: TextEditingController(text: widget.phoneNumber),
              decoration: const InputDecoration(labelText: 'Phone Number'),
              enabled: false,
            ),
          ],
        ),
      ),
      floatingActionButton: IconButton(onPressed: () async {
        Uint8List? image = await getImageBytes(_imageFile);
        ContactItem contactDetails = ContactItem(name: _nameController.text, phoneNumber: widget.phoneNumber, image: image);
        await DBHelper().insertContact(contactDetails);
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRoutes.home,
          (Route<dynamic> route) => false, // This condition removes all previous routes
        );
      }, icon: const Icon(Icons.save)),
    );
  }
}
  