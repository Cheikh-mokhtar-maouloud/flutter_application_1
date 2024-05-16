import 'dart:convert';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/Notification.dart';
import 'package:flutter_application_1/screens/video_call.dart';
import 'package:http/http.dart' as http;




class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;



  Future<void> initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  Future<void> handleBackgroundMessage(RemoteMessage? message) async {

if (message != null) {



String title = message.notification?.title ?? '';
String body = message.notification?.body ?? '';

AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: title,
        body: body,


        color: Colors.blue,

      fullScreenIntent: true,
      autoDismissible: false,
 backgroundColor: Colors.orange,
        ),
    actionButtons: [
      NotificationActionButton(
          key: 'accept', label: 'Accept', color: Colors.green,autoDismissible: true ),
      NotificationActionButton(
          key: 'decline', label: 'Decline',color: Colors.red,autoDismissible: true)
    ]);
AwesomeNotifications().setListeners(onActionReceivedMethod: (receivedNotification) async{
if (receivedNotification.buttonKeyPressed == 'accept') {
 log('accept');

  } else if (receivedNotification.buttonKeyPressed == 'decline') {
    log('decline');

 //   AwesomeNotifications().cancel(receivedNotification.id);
  }
});}
else {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: "ujjdj",
        body: "kdekldp",
        category: NotificationCategory.Call,

        color: Colors.blue,

        fullScreenIntent: true,
        autoDismissible: false,
        backgroundColor: Colors.orange,
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'accept', label: 'Accept', color: Colors.green,autoDismissible: true ),
        NotificationActionButton(
            key: 'decline', label: 'Decline',color: Colors.red,autoDismissible: true)
      ]);
  AwesomeNotifications().setListeners(onActionReceivedMethod: (receivedNotification) async{
    if (receivedNotification.buttonKeyPressed == 'accept') {
      log('accept');

    } else if (receivedNotification.buttonKeyPressed == 'decline') {
      log('decline');

      //   AwesomeNotifications().cancel(receivedNotification.id);
    }
  });


}

  }










// This creates the channel on the device and if a channel with an id already exists, it will be updated

//This is used to display the foreground notification

  static Future<void> sendAndroidNotification() async {
    try {
      http.Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAA_7bd7Vw:APA91bHhAA3rpdfQXAXvgfShg3vfiLiVlQPZn06EFXwDJejYiK4YKWRwjYXT8rEwu10voQGR2Rrzuzb3ynesuSIA8haJ7gRQk1ccerJfLJF0XkOb9T46H6j1AngHXODc_k6obic-JpLZ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body':"mohamed" ,
              'title': 'Nueva Solicitud',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': "e2DpJh2yTKq2OquU2V4amT:APA91bEntn_cKwTt7flAMpZpvv9VhGW1RV5tF3uWDhS8A1XmNZ3pFu0XVORIUgW7EYQVwDOq0DPIfl3BJcsPVSsUKwE7ne-RII03NPM_w8W3eg5PloxKIOnXx2cI09XE25noKiH1jzKZ",

          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }
  Future<void> initNotification() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,

    );
    FirebaseMessaging.instance.getInitialMessage().then(handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroundMessage
    );FirebaseMessaging.onMessage.listen(handleBackgroundMessage
    );

  }

  static Future<void> sendFCMNotification(String patientName) async {
    // Remplacez l'URL par l'URL de votre serveur qui envoie les notifications FCM
    final url = Uri.parse('https://your-server-url/send_notification');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'fcmToken':
            'dQESGd7jQQ2Cqn7sJoeElp:APA91bFV9MBQvyvOSb_UoKQnypXenwrWLvt2oIkGRkemCiYpzwLSI4MrfdvWtjRBwR6Uq0fQWFWbtKQnf6tC2LbXv0GVJ5Uj8aF4BWYC9wHjF55drITnTVGgNYI5PgiSrUSC-bgVZvxV',
        'callerName': patientName,
        'callID': '12',
      }),
    );

    if (response.statusCode == 200) {
      print('Notification envoyée avec succès');
    } else {
      print('Erreur lors de l\'envoi de la notification: ${response.body}');
    }
  }

  static Stream<QuerySnapshot> chatStream(String convertionId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('conversationId', isEqualTo: convertionId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> deleteMessage(
      String messageId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message supprimé avec succès.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du message.')),
      );
    }
  }
}


