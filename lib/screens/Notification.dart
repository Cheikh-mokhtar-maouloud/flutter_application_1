import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  static const route = '/notification-screen';

  @override
  Widget build(BuildContext context) {
    final message =
        ModalRoute.of(context)!.settings.arguments as RemoteMessage?;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Push Notification"),
      ),
      body: Center(
        child: message == null
            ? const Text('No message received.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message.notification?.title ?? 'No Title'),
                  Text(message.notification?.body ?? 'No Body'),
                  Text(message.data.toString()),
                ],
              ),
      ),
    );
  }
}
