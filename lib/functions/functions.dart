import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FunctionsSDoctor {
  static Future<void> viewPDF(String url, BuildContext context) async {
    log(url);
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
        sendMessage(null, downloadUrl, null, null, null, null, null, true);
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
      TextEditingController? _messageController,
      bool isdoctor) async {
    String friendTimeZone = 'Europe/London';

    String commonTimeUtc =
        findCommonGreenwichTime(friendTimeZone, friendTimeZone, DateTime.now())
            .subtract(Duration(hours: 1))
            .toIso8601String();
    log(commonTimeUtc);
    //true -> doctor false-> patient
    var messageDate;
    if (messageText != null && imageUrl == null && fileUrl == null) {
      messageDate = {
        'senderId': isdoctor ? doctorId : userId,
        'receiverId': isdoctor ? userId : doctorId,
        'timestamp': Timestamp.fromDate(DateTime.parse(commonTimeUtc)),
        'conversationId': _conversationId,
        'messageText': messageText,
      };
    } else if (imageUrl != null) {
      messageDate = {
        'senderId': isdoctor ? doctorId : userId,
        'receiverId': isdoctor ? userId : doctorId,
        'timestamp': Timestamp.fromDate(DateTime.now().toUtc()),
        'conversationId': _conversationId,
        "imageUrl": imageUrl
      };
    } else if (fileUrl != null) {
      messageDate = {
        'senderId': isdoctor ? doctorId : userId,
        'receiverId': isdoctor ? userId : doctorId,
        'timestamp': Timestamp.fromDate(DateTime.now().toUtc()),
        'conversationId': _conversationId,
        'fileUrl': fileUrl
      };
    } else {
      messageDate = null;
    }

    try {
      if (messageDate != null) {
        await FirebaseFirestore.instance
            .collection('messages')
            .add(messageDate);
        _messageController!.clear();
      }
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  static void initiateVideoCall(
      BuildContext context, String userId, String patientName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    log(userSnapshot.data()!['deviceId']);
    FirebaseApi.sendAndroidNotification(" video call you", patientName, userId,
        userSnapshot.data()!['deviceId']);
    final isvideo = await prefs.getBool('isVideoCall');
    if (isvideo == true) {
      // Initier l'appel vidéo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            userID: userId,
            userName: patientName,
            callID: "1234",
          ),
        ),
      );
    }
  }

  void sendVideoCallNotification(
      String patientDeviceToken, String patientName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'video_call',
        title: 'Appel vidéo entrant',
        body: 'Vous recevez un appel vidéo de $patientName',
        payload: {'callID': '12'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'accept',
          label: 'Accepter',
        ),
        NotificationActionButton(
          key: 'decline',
          label: 'Refuser',
        ),
      ],
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
        sendMessage(null, null, downloadUrl, null, null, null, null, true);
      } catch (e) {
        print("Error uploading file: $e");
      }
    }
  }

  static void navigateToPrescriptionPage(
      BuildContext context, String _doctorId, String userId, String converId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionPage(
          doctorId: _doctorId,
          userId: userId,
          conversationId: converId,
        ),
      ),
    );
  }
}

DateTime findCommonGreenwichTime(
    String myTimeZone, String friendTimeZone, DateTime myLocalTime) {
  // Initialize time zone data
  tz.initializeTimeZones();

  // Get the location for each time zone
  final myLocation = tz.getLocation(myTimeZone);
  final friendLocation = tz.getLocation(friendTimeZone);

  // Convert my local time to UTC
  final myTimeUtc = tz.TZDateTime.from(myLocalTime, myLocation).toUtc();

  // Convert friend's time to UTC using my UTC time and friend's time zone
  final friendTimeUtc = tz.TZDateTime.from(myTimeUtc, friendLocation);

  // Find the midpoint between myTime and friendTime
  final halfDifference = friendTimeUtc.difference(myTimeUtc) ~/ 2;
  final commonTimeUtc = myTimeUtc.add(halfDifference);

  return commonTimeUtc;
}
