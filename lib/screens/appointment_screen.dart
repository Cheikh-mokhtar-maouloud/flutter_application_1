import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
import 'package:flutter_application_1/screens/reservation.dart';
import 'package:flutter_application_1/screens/video_call.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorImg;
  final String doctorName;
  final String rating;
  final List<Map<String, dynamic>> allDoctors;
  final String doctorAddress; // Ajoutez cette ligne

  AppointmentScreen({
    required this.doctorId,
    required this.doctorImg,
    required this.doctorName,
    required this.rating,
    required this.allDoctors,
    required this.doctorAddress, // Ajoutez cette ligne
  });

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  Doctor? selectedDoctor;
  String? doctorIdForUser;
  bool hasReservation = false;
  bool isLoading = true; // Ajouter un booléen pour gérer l'état de chargement
  @override
  void initState() {
    super.initState();
    fetchDoctorDetails(widget.doctorId).then((_) {
      fetchDoctorIdForUser();
    });
  }

  // void _startVideoCall() async {
  //   // Récupérer l'ID de l'utilisateur connecté (callerId)
  //   String callerId = FirebaseAuth.instance.currentUser?.uid ?? '';

  //   // Récupérer l'ID du médecin sélectionné (recipientId)
  //   String recipientId = widget.doctorId;

  //   // Enregistrer les informations dans la base de données Firebase
  //   await FirebaseFirestore.instance.collection('appele_video').add({
  //     'callerId': callerId,
  //     'recipientId': recipientId,
  //     'status': 'ongoing',
  //     'startTime': DateTime.now().toIso8601String(),
  //   });

  //   // Après avoir enregistré les informations, vous pouvez démarrer l'appel vidéo
  //   // Ici, vous pouvez naviguer vers une autre page où se déroulera l'appel vidéo
  //   // par exemple, une page dédiée à l'appel vidéo (VideoCallScreen)
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => VideoCallScreen()),
  //   );
  // }

  Future<String?> getDoctorIdForUser(String userId) async {
    QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('id_utilisateur', isEqualTo: userId)
        .get();

    if (reservationSnapshot.docs.isNotEmpty) {
      // Récupérez l'identifiant du premier médecin avec lequel l'utilisateur a réservé
      return reservationSnapshot.docs.first.get('id_doctor');
    } else {
      // Aucune réservation trouvée pour cet utilisateur
      return null;
    }
  }

  Future<void> fetchDoctorIdForUser() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String? doctorId = await getDoctorIdForUser(userId);
    setState(() {
      doctorIdForUser = doctorId;
    });
  }

  Future<void> fetchDoctorDetails(String doctorId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doctorSnapshot =
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(doctorId)
              .get();

      if (doctorSnapshot.exists) {
        Map<String, dynamic> doctorData = doctorSnapshot.data()!;
        setState(() {
          selectedDoctor = Doctor(
              nom: doctorData['Nom'],
              description: doctorData['description'],
              evaluation: doctorData['Evaluation'],
              numeroTel: doctorData['NumeroTel'],
              image: doctorData['Image'],
              Adresse: doctorData['adresse']);
          isLoading = false; // Chargement terminé
        });
      } else {
        setState(() {
          isLoading =
              false; // Chargement terminé même si le docteur n'existe pas
        });
        // Gérer le cas où le docteur n'existe pas dans la base de données
      }
    } catch (e) {
      setState(() {
        isLoading =
            false; // Assurez-vous de stopper le chargement en cas d'erreur
      });
      // Gérer l'exception
    }
  }

  Future<void> _navigateToChatIfReservationExists() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          doctorImg: widget.doctorImg,
        ),
      ),
    );
  }

  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme l'alerte
              },
            ),
          ],
        );
      },
    );
  }

  // Future<bool> checkReservation(String userId, String doctorId) async {
  //   QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
  //       .collection('reservations')
  //       .where('userId', isEqualTo: userId)
  //       .where('doctorId', isEqualTo: doctorId)
  //       .get();

  //   return reservationSnapshot.docs.isNotEmpty;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7165D6),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Affiche un indicateur de chargement
          : buildLoadedUI(), // Méthode pour construire l'interface utilisateur chargée
    );
  }

  @override
  Widget buildLoadedUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: selectedDoctor != null
                            ? NetworkImage(selectedDoctor!.image)
                            : null,
                      ),
                      SizedBox(height: 15),
                      Text(
                        selectedDoctor != null ? selectedDoctor!.nom : '',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _navigateToChatIfReservationExists,
                            child: Text("Chat avec le docteur"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          selectedDoctor != null
              ? buildDoctorDetails()
              : Container(), // Afficher les détails du médecin s'il est sélectionné
        ],
      ),
    );
  }

  Widget buildDoctorDetails() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "À propos de médecin",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            selectedDoctor!.description,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Evaluation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Icon(Icons.star, color: Colors.amber),
              Text(
                selectedDoctor!.evaluation.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 5),
              Text(
                "(124)",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "L'adresse",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFF0EEFA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: Color(0xFF7165D6),
                size: 30,
              ),
            ),
            title: Text(
              selectedDoctor!.Adresse,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            subtitle: Text("Mauritanie"),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Prix ​​​​des consultations",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "\100 UM-N",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationPage(
                    doctorName: selectedDoctor!.nom,
                    doctorImg: selectedDoctor!.image,
                    doctorId: widget.doctorId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7165D6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 15),
              minimumSize: Size(double.infinity, 0),
            ),
            child: Text(
              "Prendre un rendez-vous",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Doctor {
  final String nom;
  // final String specialite;
  final String description;
  final String evaluation;
  final String numeroTel;
  final String image;
  final String Adresse;

  Doctor(
      {required this.nom,
      // required this.specialite,
      required this.description,
      required this.evaluation,
      required this.numeroTel,
      required this.image,
      required this.Adresse});
}
