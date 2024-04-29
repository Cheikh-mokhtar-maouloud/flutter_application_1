import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Assurez-vous d'avoir ajouté intl à vos dépendances

class ScheduleScreen extends StatefulWidget {
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
  }

  Future<String> getDoctorName(String doctorId) async {
    DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .get();
    return doctorSnapshot.exists
        ? doctorSnapshot.get('Nom') ?? 'Nom inconnu'
        : 'Docteur non trouvé';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Le nombre d'onglets
      child: Scaffold(
        appBar: AppBar(
          title: Text("Vos Réservations"),
          bottom: TabBar(
            tabs: [
              Tab(text: 'À venir'),
              Tab(text: 'Terminé'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReservationList(
                isUpcoming: true), // Liste des réservations à venir
            _buildReservationList(
                isUpcoming: false), // Liste des réservations terminées
          ],
        ),
      ),
    );
  }

  Widget _buildReservationList({required bool isUpcoming}) {
    // Création d'un objet Timestamp de l'instant présent
    Timestamp now = Timestamp.fromDate(DateTime.now());

    // Création de la requête en fonction de l'onglet sélectionné
    Query<Map<String, dynamic>> reservationsQuery = FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: _user.uid);

    // Si on veut les réservations à venir, on filtre pour celles après maintenant
    if (isUpcoming) {
      reservationsQuery = reservationsQuery.where('date', isGreaterThan: now);
    } else {
      // Pour les réservations terminées, on filtre pour celles avant maintenant
      reservationsQuery = reservationsQuery.where('date', isLessThan: now);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: reservationsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          // Filtre supplémentaire pour les dates passées après avoir reçu les données
          var documents =
              snapshot.data!.docs.where((DocumentSnapshot document) {
            Timestamp date = document['date'];
            return isUpcoming
                ? date.toDate().isAfter(DateTime.now())
                : date.toDate().isBefore(DateTime.now());
          }).toList();

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = documents[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              String doctorId = data['doctorId'];
              DateTime date;
              if (data['date'] is Timestamp) {
                date = (data['date'] as Timestamp).toDate();
              } else if (data['date'] is String) {
                date =
                    DateFormat('your_string_date_format').parse(data['date']);
              } else {
                // Handle the case where the date is neither a Timestamp nor a String
                // You may want to log this case or handle it with an appropriate UI
                return Text('Invalid date format');
              }

              String formattedDate = DateFormat('dd/MM/yyyy').format(date);
              String time = data['time'];
              String type = data['type'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                elevation: 2,
                child: ListTile(
                  title: FutureBuilder<String>(
                    future: getDoctorName(doctorId),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Chargement du nom...");
                      } else if (snapshot.hasError) {
                        return Text("Erreur lors du chargement");
                      } else {
                        return Text(snapshot.data!); // Le nom du docteur
                      }
                    },
                  ),
                  subtitle: Text('$formattedDate à $time - $type'),
                ),
              );
            },
          );
        } else {
          return Center(
              child: Text(
                  'Aucune réservation ${isUpcoming ? "à venir" : "terminée"} trouvée'));
        }
      },
    );
  }
}
