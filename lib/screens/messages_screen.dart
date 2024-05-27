import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<List<Map<String, dynamic>>> _doctorsWithReservations;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  @override
  void initState() {
    super.initState();
    _doctorsWithReservations = _getDoctorsWithReservations();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
    });
  }

  Future<List<Map<String, dynamic>>> _getDoctorsWithReservations() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final now = Timestamp.now();
    final reservationsSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: now)
        .get();

    List<Map<String, dynamic>> doctors = [];
    for (var reservation in reservationsSnapshot.docs) {
      // Vérifiez si le type de la réservation est "en_ligne"
      String type = reservation.data()['type'] ?? "";
      if (type == "en_ligne") {
        final doctorId = reservation.data()['doctorId'];
        final reservationDate = reservation.data()['date'] as Timestamp;
        final doctorSnapshot = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctorId)
            .get();
        if (doctorSnapshot.exists) {
          doctors.add({
            'doctorId': doctorId,
            'doctorName': doctorSnapshot.data()!['Nom'],
            'doctorImg': doctorSnapshot.data()!['Image'],
            'reservationDate': reservationDate,
          });
        }
      }
    }

    return doctors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search médecins...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _doctorsWithReservations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(child: Text('No Doctor trouvable.'));
                }

                // Filter the doctors based on the search text
                var filteredDoctors = snapshot.data!
                    .where((doctor) => doctor['doctorName']
                        .toLowerCase()
                        .contains(_searchText.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = filteredDoctors[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(doctor['doctorImg']),
                      ),
                      title: Text(doctor['doctorName']),
                      subtitle: Text('Tap to chat with the doctor.'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              doctorId: doctor['doctorId'],
                              doctorName: doctor['doctorName'],
                              doctorImg: doctor['doctorImg'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
