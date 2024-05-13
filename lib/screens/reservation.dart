import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/datedoctor.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReservationPage extends StatefulWidget {
  final String doctorName;
  final String doctorImg;
  final String doctorId;

  ReservationPage({
    required this.doctorName,
    required this.doctorImg,
    required this.doctorId,
  });

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  bool _hasUpcomingReservation = false;

  @override
  void initState() {
    super.initState();
    _checkForUpcomingReservations();
  }

  void _checkForUpcomingReservations() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var now = Timestamp.fromDate(DateTime.now());
      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: user.uid)
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('date', isGreaterThan: now)
          .get();

      setState(() {
        _hasUpcomingReservation = reservationSnapshot.docs.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Réservation avec Dr. ${widget.doctorName}'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'En ligne'),
              Tab(text: 'Présentiel'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAvailabilitiesList('en_ligne'),
            _buildAvailabilitiesList('presentiel'),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitiesList(String type) {
    var now = Timestamp.fromDate(DateTime.now());
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('availabilities')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('type', isEqualTo: type)
          .where('reserved', isEqualTo: false)
          .where('date', isGreaterThan: now)
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Erreur: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            DateTime dateTime = (data['date'] as Timestamp).toDate();
            String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

            return ListTile(
              title: Text('$formattedDate - ${data['time']}'),
              subtitle: Text(data['type']),
              trailing: ElevatedButton(
                onPressed: () {
                  if (type == 'en_ligne') {
                    _makeOnlineReservation(document.id, data['time']);
                  } else {
                    _chooseInPersonOrOnline(document.id, data['time']);
                  }
                },
                child: Text('Réserver'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _chooseInPersonOrOnline(
      String availabilityId, String time) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisir une option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer la boîte de dialogue
                  _makeInPersonReservation(availabilityId, time);
                },
                child: Text('Présentiel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer la boîte de dialogue
                  _makeOnlineReservation(availabilityId, time);
                },
                child: Text('En ligne'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _makeOnlineReservation(
      String availabilityId, String time) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour réserver.')),
      );
      return;
    }

    bool success = await _stripeMakePayment();
    if (success) {
      DocumentReference availabilityRef = FirebaseFirestore.instance
          .collection('availabilities')
          .doc(availabilityId);

      DocumentSnapshot availabilitySnapshot = await availabilityRef.get();
      if (availabilitySnapshot.exists) {
        Map<String, dynamic> availabilityData =
            availabilitySnapshot.data()! as Map<String, dynamic>;
        if (!availabilityData['reserved']) {
          await FirebaseFirestore.instance.collection('reservations').add({
            'userId': user.uid,
            'doctorId': widget.doctorId,
            'availabilityId': availabilityId,
            'time': time,
            'date': availabilityData['date'],
            'type': 'en_ligne',
          });

          await availabilityRef.update({'reserved': true});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Réservation en ligne réussie.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cette disponibilité est déjà réservée.')),
          );
        }
      }
    }
  }

  Future<void> _makeInPersonReservation(
      String availabilityId, String time) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour réserver.')),
      );
      return;
    }

    // Vérifiez s'il y a déjà une réservation à venir avec ce médecin
    var now = Timestamp.fromDate(DateTime.now());
    QuerySnapshot existingReservations = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .where('doctorId', isEqualTo: widget.doctorId)
        .where('date', isGreaterThan: now)
        .get();

    if (existingReservations.docs.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Réservation en attente"),
            content:
                Text("Vous avez déjà une réservation à venir avec ce médecin."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    DocumentReference availabilityRef = FirebaseFirestore.instance
        .collection('availabilities')
        .doc(availabilityId);

    DocumentSnapshot availabilitySnapshot = await availabilityRef.get();
    if (availabilitySnapshot.exists) {
      Map<String, dynamic> availabilityData =
          availabilitySnapshot.data()! as Map<String, dynamic>;

      if (!availabilityData['reserved']) {
        await FirebaseFirestore.instance.collection('reservations').add({
          'userId': user.uid,
          'doctorId': widget.doctorId,
          'availabilityId': availabilityId,
          'time': time,
          'date': availabilityData['date'],
          'type': 'presentiel',
        });

        await availabilityRef.update({'reserved': true});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réservation en personne réussie.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cette disponibilité est déjà réservée.')),
        );
      }
    }
  }

  Future<bool> _stripeMakePayment() async {
    try {
      final paymentIntent = await _createPaymentIntent('100', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'MedApp',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      // Affichez une notification ou une boîte de dialogue pour confirmer le succès du paiement
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Paiement Réussi"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                    'images/secc.png'), // Remplacez 'images/success.png' par le chemin de votre image
                SizedBox(height: 10),
                Text("Le paiement a été effectué avec succès."),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );

      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erreur: ${e.toString()}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent(
      String amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded',
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
}
