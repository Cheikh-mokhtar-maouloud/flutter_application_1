import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginFunctions{
  static Future<void> loginandupdate(UserCredential userCredential) async {
    if (userCredential.user != null) {
      // Get a reference to the user document
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
      final token =await FirebaseMessaging.instance.getToken();
      // Update the specified field with the new value
      await userRef.update({"deviceId": token});
    }
  }
}