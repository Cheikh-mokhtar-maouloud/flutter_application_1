import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Api/firebase_api.dart';
import 'package:flutter_application_1/Api/notificationApi.dart';
import 'package:flutter_application_1/screens/chatdoctor.dart';
import 'package:flutter_application_1/screens/ordonence.dart';
import 'package:flutter_application_1/screens/video_call.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FunctionsSDoctor {
  static Future<void> viewPDF(String url, BuildContext context) async {
    var response = await http.get(Uri.parse(url));
    var documentDirectory = await getTemporaryDirectory();
    var filePathAndName = documentDirectory.path + '/tempPdf.pdf';
    File file = File(filePathAndName);
    file.writeAsBytesSync(response.bodyBytes);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFViewPage(filePath: filePathAndName)));
  }

  static downloadFile(String url, String fileName) async {
    var response = await http.get(Uri.parse(url));
    var documentDirectory = await getTemporaryDirectory();
    File file = new File('${documentDirectory.path}/$fileName');
    file.writeAsBytesSync(response.bodyBytes);
    // Optionally, inform the user about the download completion or open the file.
  }

  static void pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      String fileName =
          'chat_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);

      try {
        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();
        sendMessage(null, downloadUrl, null, null, null, null, null);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  static Future<void> sendMessage(
      String? messageText,
      String? imageUrl,
      String? fileUrl,
      String? doctorId,
      String? userId,
      String? _conversationId,
      TextEditingController? _messageController) async {
    if (messageText != null || imageUrl != null || fileUrl != null) {
      var messageData = {
        'senderId': doctorId,
        'receiverId': userId,
        'timestamp': Timestamp.now(),
        'conversationId': _conversationId,
        'messageText': messageText,
        'imageUrl': imageUrl,
        'fileUrl': fileUrl,
      };

      try {
        await FirebaseFirestore.instance
            .collection('messages')
            .add(messageData);
        _messageController!.clear();
      } catch (e) {
        log('Error sending message: $e');
      }
    }
  }

  static void initiateVideoCall(
      BuildContext context, String userId, String patientName) async {
String? token =await FirebaseMessaging.instance.getToken();
FirebaseApi.sendAndroidNotification();
log('Token: $token');
    // Initier l'appel vidéo
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          userID: userId,
          userName: patientName,
        ),
      ),
    );
  }

  static void pickFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName =
          'chat_files/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);

      try {
        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();
        sendMessage(null, null, downloadUrl, null, null, null, null);
      } catch (e) {
        print("Error uploading file: $e");
      }
    }
  }

  static void navigateToPrescriptionPage(
      BuildContext context, String _doctorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionPage(doctorId: _doctorId),
      ),
    );
  }
}
