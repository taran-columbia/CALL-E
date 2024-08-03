import 'dart:typed_data';

class ContactItem {
  final int? id;
  final String name;
  final String phoneNumber;
  final Uint8List? image;

  ContactItem({this.id, required this.name, required this.phoneNumber, this.image});

  

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'image': image,
    };
  }
}
