import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Map<String, dynamic>? paymentIntent;

  Future<void> stripeMakePayment() async {
    try {
      final patientInfo = await _getPatientInfo(); // Fetch patient's info

      paymentIntent = await _createPaymentIntent('100', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          billingDetails: BillingDetails(
            name: patientInfo['name'],
            email: patientInfo['email'],
            phone: patientInfo['phone'],
            address: Address(
              city: patientInfo['city'],
              country: patientInfo['country'],
              line1: patientInfo['line1'],
              line2: patientInfo['line2'],
              postalCode: patientInfo['postalCode'],
              state: patientInfo['state'],
            ),
          ),
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'MedApp',
        ),
      );

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      Fluttertoast.showToast(msg: 'Payment successfully completed.');
    } on Exception catch (e) {
      if (e is StripeException) {
        Fluttertoast.showToast(
            msg: 'Stripe Error: ${e.error.localizedMessage}');
      } else {
        Fluttertoast.showToast(msg: 'Unexpected Error: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _getPatientInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    }

    return {
      'name': '',
      'email': '',
      'phone': '',
      'city': '',
      'country': '',
      'line1': '',
      'line2': '',
      'postalCode': '',
      'state': '',
    };
  }

  Future<Map<String, dynamic>?> _createPaymentIntent(
      String amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': (int.parse(amount) * 100).toString(),
          'currency': currency,
        },
      );

      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment '),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            stripeMakePayment(); // Call the method to make a payment
          },
          child: Text('Réserver'),
        ),
      ),
    );
  }
}
