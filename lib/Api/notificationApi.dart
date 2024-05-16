import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
  }

  Future<void> initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    log('Token: $fcmToken');

    await initPushNotification();

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
    });
  }

  static Future<void> sendFCMNotification(String patientName) async {
    // Remplacez l'URL par l'URL de votre serveur qui envoie les notifications FCM
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send<');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            "AAAA_7bd7Vw:APA91bHhAA3rpdfQXAXvgfShg3vfiLiVlQPZn06EFXwDJejYiK4YKWRwjYXT8rEwu10voQGR2Rrzuzb3ynesuSIA8haJ7gRQk1ccerJfLJF0XkOb9T46H6j1AngHXODc_k6obic-JpLZ"
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
}
