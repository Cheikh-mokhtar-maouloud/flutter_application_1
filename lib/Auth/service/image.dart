import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> ExtractImage(BuildContext context, ImagePicker _picker,String? url) async {
  Navigator.of(context).pop();
  final XFile? image =
  await _picker.pickImage(source: ImageSource.camera);
  if (image != null) {
    File file = File(image.path);
    String fileName =
    DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('profile_images/$fileName');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot storageTaskSnapshot =
    await uploadTask.whenComplete(() {});
    String downloadUrl =
    await storageTaskSnapshot.ref.getDownloadURL();
    url = downloadUrl;
  }
}