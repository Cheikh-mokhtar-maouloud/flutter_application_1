import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/appointment_screen.dart';

class AllDoctorsScreen extends StatefulWidget {
  @override
  _AllDoctorsScreenState createState() => _AllDoctorsScreenState();
}

class _AllDoctorsScreenState extends State<AllDoctorsScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Doctors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by name',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: (searchQuery.isEmpty)
                ? FirebaseFirestore.instance.collection('doctors').snapshots()
                : FirebaseFirestore.instance
                    .collection('doctors')
                    .where('Nom', isGreaterThanOrEqualTo: searchQuery)
                    .where('Nom', isLessThanOrEqualTo: searchQuery + '\uf8ff')
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('An error occurred'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No doctors found'));
              }

              final docs = snapshot.data!.docs;

              // ...
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  // Obtenez le 'DocumentSnapshot' pour le document courant
                  DocumentSnapshot docSnapshot = docs[index];

                  // Accédez à l'ID du document et aux données du document
                  String docId = docSnapshot.id; // l'ID du médecin
                  Map<String, dynamic> docData =
                      docSnapshot.data() as Map<String, dynamic>;

                  return ListTile(
                    onTap: () {
                      // Utilisez 'docId' pour l'ID du médecin
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentScreen(
                            doctorId: docSnapshot.id,
                            doctorImg: docData['Image'],
                            doctorName: docData['Nom'],
                            rating: docData['Evaluation'],
                            allDoctors: [], // ou passez la liste complète si nécessaire
                            // Ajoutez l'adresse ici
                            doctorAddress: docData[
                                'adresse'], // Assurez-vous que 'adresse' correspond au champ Firestore
                          ),
                        ),
                      );
                    },
                    // Utilisez 'docData' pour accéder aux autres données du document
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(docData['Image']),
                    ),
                    title: Text(docData['Nom']),
                    subtitle: Text(
                        'Évaluation: ${docData['Evaluation']?.toString() ?? 'Not rated'}'),
                  );
                },
              );
// ...
            },
          )),
        ],
      ),
    );
  }
}
