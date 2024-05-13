import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/components/spachScreen.dart';
import 'package:flutter_application_1/payment.dart';

import 'package:flutter_application_1/screens/logindoctor.dart';
import 'package:flutter_application_1/screens/signdoctor.dart';

import 'package:flutter_application_1/widgets/navbar_roots.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PreferenceUtils.init();

  Stripe.publishableKey =
      'pk_test_51PB14uIfVECIDkkVM1sL3V02yPEJookC8YtSvSzeXdEbLQSweBvbDhcyRul0UpM7F2Joj6NDfap0n6pmrvrLCHGQ00MjPaJKvZ';
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
        //debugPrint
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? SplashScreen()
          : NavBarRoots(),
    );
  }
}

class PreferenceUtils {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static String getString(String key, {String defaultValue = ''}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  static Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  static Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }
}
