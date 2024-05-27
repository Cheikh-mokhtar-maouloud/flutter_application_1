import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Auth/sign_up_screen.dart';
import 'package:flutter_application_1/screens/alldoctor.dart';

import 'package:flutter_application_1/screens/appointment_screen.dart';
import 'package:flutter_application_1/screens/logindoctor.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';
import 'package:flutter_application_1/screens/signdoctor.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  static const route = '/HomeScreen';
  _HomeScreenState createState() => _HomeScreenState();
}

List<String> symptoms = [
  "Anesthésiologie",
  "kinésithérapeute",
  "Cardiologie",
  "Dermatologie",
  "Endocrinologie",
  "Gériatrie",
  "Gynécologie",
  "Hématologie",
  "Infectiologie",
  "Médecine interne",
  "Médecine générale",
];

List<IconData> icons = [
  Icons.accessibility,
  Icons.favorite,
  Icons.color_lens,
  Icons.all_inclusive,
  Icons.accessible_forward,
  Icons.pregnant_woman,
  Icons.healing,
  Icons.masks,
  Icons.local_hospital,
  Icons.healing
];

List<String> filteredSymptoms = [];

List<double> doctorRatings = [
  4.9,
  4.5,
  4.7,
  4.8,
];

String extractFirstWord(String fullName) {
  List<String> words = fullName.split(' ');
  return words.isNotEmpty ? words[0] : '';
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> selectedDoctors = [];
  late Future<DocumentSnapshot> _doctorFuture;
  String selectedSymptom = '';
  late Future<String> _userNameFuture;
  late Future<String> _userImageUrlFuture;
  bool isDataLoaded = false;
  List<Map<String, dynamic>> doctors = [];
  Future<String> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserName = prefs.getString('userName');

    if (storedUserName != null && storedUserName.isNotEmpty) {
      return storedUserName;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userName = '';
        if (user.providerData
            .any((provider) => provider.providerId == "google.com")) {
          userName = user.displayName ?? '';
        } else {
          try {
            final DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get();

            if (userDoc.exists && userDoc.data() != null) {
              final userData = userDoc.data() as Map<String, dynamic>;
              userName = userData["name"] ?? '';
            } else {
              // Handle the case where the document does not exist or data is null
              userName = 'Unknown User';
            }
          } catch (e) {
            // Handle potential errors in fetching the document
            print('Error fetching user document: $e');
            userName = 'Unknown User';
          }
        }

        await prefs.setString('userName', userName);
        return userName;
      }
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> _getAllDoctors() async {
    List<Map<String, dynamic>> doctors = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();

    snapshot.docs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> doctorData = doc.data();
      doctors.add(doctorData);
    });

    return doctors;
  }

  Future<void> _loadData() async {
    doctors = await _getAllDoctors();
    setState(() {
      isDataLoaded = true;
    });
  }

  String extractFirstWord(String fullName) {
    List<String> words = fullName.split(' ');
    return words.isNotEmpty ? words[0] : '';
  }

  void filterDoctorsBySymptom(String symptom) {
    setState(() {
      selectedSymptom = symptom;
      selectedDoctors = [];
    });
  }

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialisez `_doctorFuture` ici
    _doctorFuture = FirebaseFirestore.instance
        .collection('doctors')
        .doc('PHQ3FGaB0urFjsrjQyPM')
        .get();

    _userNameFuture = _getUserName();
    _userImageUrlFuture = _getUserImageUrl();
    _loadData();
  }

  Future<String> _getUserImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedImageUrl = prefs.getString('userImageUrl');

    if (storedImageUrl != null && storedImageUrl.isNotEmpty) {
      return storedImageUrl;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String imageUrl = '';
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>;
        imageUrl = userData["photoUrl"] ?? '';

        await prefs.setString('userImageUrl', imageUrl);
        return imageUrl;
      }
      return '';
    }
  }

  void filterSymptoms(String query) {
    List<String> filteredList = symptoms
        .where((symptom) => symptom.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredSymptoms = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder(
                      future: _getUserName(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            String firstName = extractFirstWord(snapshot.data!);

                            return Text(
                              "Bonjour, $firstName",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                    FutureBuilder(
                      future: _userImageUrlFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingScreen(),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(snapshot.data!),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                // Ajoutez ici la logique que vous souhaitez exécuter lorsqu'on tape sur l'avatar
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage("images/doctor1.jpg"),
                              ),
                            );
                          }
                        } else {
                          return CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage("images/doctor1.jpg"),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey[100]),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: filterSymptoms,
                          decoration: InputDecoration(
                            hintText: 'spécialité',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          // Lorsque l'icône de recherche est pressée, réinitialisez le filtre de symptôme
                          setState(() {
                            selectedSymptom =
                                ''; // Réinitialisez le filtre de symptôme pour afficher tous les médecins
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: symptoms.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        filterDoctorsBySymptom(symptoms[index]);
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F6FA),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icons[index],
                              color: Color(0xFF7165D6),
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              symptoms[index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "Médecins",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: selectedSymptom.isEmpty
                      ? FirebaseFirestore.instance
                          .collection('doctors')
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('doctors')
                          .where('symptoms',
                              isEqualTo:
                                  selectedSymptom) // ou 'arrayContains' si le champ est un tableau
                          .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return CircularProgressIndicator();
                      default:
                        // Vérifiez si la liste des médecins est vide après le filtrage
                        if (snapshot.data?.docs.isEmpty ?? true) {
                          return Text(
                              'No doctors found for this symptom.'); // Afficher un message si aucun médecin n'est trouvé
                        }
                    }
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> doctorData =
                            document.data() as Map<String, dynamic>;
                        String doctorId = document
                            .id; // Utilisez `document.id` pour obtenir l'ID unique du médecin
                        String doctorImg =
                            doctorData['Image'] ?? ''; // Image URL
                        String doctorName =
                            doctorData['Nom'] ?? ''; // Nom du médecin
                        String Evaluation = doctorData['Evaliation'] ?? '';
                        String adresse = doctorData['adresse'] ?? '';
                        String symptoms = doctorData['symptoms'] ?? '';
                        //... (autres attributs)

                        return InkWell(
                          onTap: () {
                            print(doctorId);
                            // Lorsque vous cliquez sur le médecin, vous passez son ID unique à AppointmentScreen
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AppointmentScreen(
                                doctorId:
                                    doctorId, // Passer l'ID unique du médecin
                                doctorImg: doctorImg,
                                doctorName: doctorName,
                                rating: Evaluation.toString(),
                                allDoctors: [],
                                doctorAddress: adresse,
                                // Si vous avez besoin de passer la liste des médecins
                              ),
                            ));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage: NetworkImage(doctorImg),
                                ),
                                Text(
                                  doctorName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 5),
                                    Text(
                                      symptoms,
                                      style: TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AllDoctorsScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.medical_services), // Ajoute l'icône ici
                      label: Text(
                        'Tous les médecins',
                      ), // Texte du bouton
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SignUpScreendoc()));
                      },
                      child: Text('sign_doctor'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
