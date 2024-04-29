import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/datedoctor.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';
import 'package:intl/intl.dart';

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
      length: 2, // Nombre d'onglets
      child: Scaffold(
        appBar: AppBar(
          title: Text('Réservation avec Dr.${widget.doctorName}'),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddAvailabilityPage(
                        doctorId: widget.doctorId,
                      ),
                    ),
                  );
                },
                child: Text("pass")),
          ],
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
          .where('date', isGreaterThan: now) // Filtrer les dates passées
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
                  _makeReservation(document.id, data['time'], data['type']);
                },
                child: Text('Réserver'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _makeReservation(String availabilityId, String time, String type) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Vérifiez s'il y a déjà une réservation à venir avec ce médecin.
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
              title: Text('Réservation existante'),
              content: Text(
                  'Vous avez déjà une réservation à venir avec ce médecin.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme la boîte de dialogue
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      // Référence au document de la disponibilité choisie
      DocumentReference availabilityRef = FirebaseFirestore.instance
          .collection('availabilities')
          .doc(availabilityId);

      // Récupérer le document de la disponibilité pour s'assurer qu'elle n'est pas déjà réservée
      DocumentSnapshot availabilitySnapshot = await availabilityRef.get();
      if (availabilitySnapshot.exists) {
        Map<String, dynamic> availabilityData =
            availabilitySnapshot.data() as Map<String, dynamic>;

        // Vérifier que le créneau n'est pas déjà réservé
        if (availabilityData['reserved'] != true) {
          // Effectuer la réservation
          await FirebaseFirestore.instance.collection('reservations').add({
            'userId': user.uid,
            'doctorId': widget.doctorId,
            'availabilityId': availabilityId,
            'time': time,
            'type': type,
            'date': availabilityData['date'],
          });

          // Mettre à jour le créneau de disponibilité comme réservé
          await availabilityRef.update({'reserved': true});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Réservation effectuée avec succès.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cette disponibilité est déjà réservée.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La disponibilité n\'est plus disponible.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Vous devez être connecté pour faire une réservation.')),
      );
    }
  }
}
