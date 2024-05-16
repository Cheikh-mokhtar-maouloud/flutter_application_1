import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Api/homePageApi/homePageApi.dart';
import 'package:flutter_application_1/model/doctor.dart';
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

  Future<void> fetchDoctorIdForUser() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String? doctorId = await HomePageApi.getDoctorIdForUser(userId);
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
          selectedDoctor = Doctor.fromJson(doctorData);
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
                        icon: IconAdd(Icons.arrow_back_ios_new, 25)),
                    IconAdd(Icons.more_vert, 28),
                  ],
                ),
                ChatAVecDoctorWidget(),
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

  Padding ChatAVecDoctorWidget() {
    return Padding(
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
    );
  }

  Icon IconAdd(IconData icon, double size) {
    return Icon(
      icon,
      color: Colors.white,
      size: size,
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
          firstRow(),
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

  Row firstRow() {
    return Row(
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
    );
  }
}
