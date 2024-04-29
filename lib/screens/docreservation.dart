import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_application_1/screens/chatdoctor.dart';
import 'package:intl/intl.dart'; // Assurez-vous que le chemin d'accès est correct

class DoctorsScreen extends StatefulWidget {
  @override
  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> _getReservationsWithPatientDetails() {
    if (_auth.currentUser == null) {
      print("Aucun utilisateur connecté.");
      return Stream.value(
          []); // Retourne une liste vide si aucun utilisateur n'est connecté.
    } else {
      return FirebaseFirestore.instance
          .collection('reservations')
          .where('doctorId', isEqualTo: _auth.currentUser!.uid)
          .snapshots()
          .asyncMap((snapshot) async {
        List<Map<String, dynamic>> reservationsWithDetails = [];
        for (var reservation in snapshot.docs) {
          var patientSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(reservation['userId'])
              .get();

          // Vérifiez que le patientSnapshot existe avant d'essayer d'accéder aux champs
          if (patientSnapshot.exists) {
            Map<String, dynamic> patientData = patientSnapshot.data()!;
            Map<String, dynamic> details = {
              'patientName': patientData['name'],
              'patientPhoto': patientData['photoUrl'],
              'date': reservation['date'].toDate(),
              'userId': reservation['userId']
            };
            reservationsWithDetails.add(details);
          } else {
            // Gérer le cas où le patient n'existe pas
            print(
                'Patient snapshot does not exist for userId: ${reservation['userId']}');
          }
        }
        return reservationsWithDetails;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients avec réservations'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getReservationsWithPatientDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Erreur: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> reservations = snapshot.data ?? [];
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              var reservation = reservations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(reservation['patientPhoto']),
                ),
                title: Text(reservation['patientName']),
                subtitle: Text(
                    'Rendez-vous le: ${DateFormat('dd/MM/yyyy').format(reservation['date'])}'),
                onTap: () {
                  // Naviguer vers le chat avec ce patient
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chatdoc(
                          userId: reservation['userId'],
                          doctorId: _auth.currentUser!.uid,
                        ),
                      ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
