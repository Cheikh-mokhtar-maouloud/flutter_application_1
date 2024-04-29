import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Auth/sign_up_screen.dart';
import 'package:flutter_application_1/screens/alldoctor.dart';

import 'package:flutter_application_1/screens/appointment_screen.dart';
import 'package:flutter_application_1/screens/logindoctor.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';
import 'package:flutter_application_1/screens/signdoctor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

List<String> symptoms = [
  "Anesthésiologie",
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
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();
          final userData = userDoc.data() as Map<String, dynamic>;
          userName = userData["name"] as String;
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

              // SizedBox(height: 5),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     InkWell(
              //       onTap: () {},
              //       child: Container(
              //         width: 360,
              //         padding: EdgeInsets.all(20),
              //         decoration: BoxDecoration(
              //           color: Color(0xFF7165D6),
              //           borderRadius: BorderRadius.circular(10),
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black12,
              //               blurRadius: 6,
              //               spreadRadius: 4,
              //             ),
              //           ],
              //         ),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Container(
              //               padding: EdgeInsets.all(8),
              //               decoration: BoxDecoration(
              //                 color: Colors.white,
              //                 shape: BoxShape.circle,
              //               ),
              //               child: Icon(
              //                 Icons.add,
              //                 color: Color(0xFF7165D6),
              //                 size: 35,
              //               ),
              //             ),
              //             SizedBox(height: 30),
              //             Text(
              //               "Clinic Visit",
              //               style: TextStyle(
              //                 fontSize: 18,
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //             SizedBox(height: 5),
              //             Text(
              //               "Make an appointment",
              //               style: TextStyle(
              //                 color: Colors.white54,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //     // InkWell(
              //     //   onTap: () {},
              //     //   child: Container(
              //     //     padding: EdgeInsets.all(20),
              //     //     decoration: BoxDecoration(
              //     //       color: Colors.white,
              //     //       borderRadius: BorderRadius.circular(10),
              //     //       boxShadow: [
              //     //         BoxShadow(
              //     //           color: Colors.black12,
              //     //           blurRadius: 6,
              //     //           spreadRadius: 4,
              //     //         ),
              //     //       ],
              //     //     ),
              //     //     child: Column(
              //     //       crossAxisAlignment: CrossAxisAlignment.start,
              //     //       children: [
              //     //         Container(
              //     //           padding: EdgeInsets.all(8),
              //     //           decoration: BoxDecoration(
              //     //             color: Color(0xFFF0EEFA),
              //     //             shape: BoxShape.circle,
              //     //           ),
              //     //           child: Icon(
              //     //             Icons.home_filled,
              //     //             color: Color(0xFF7165D6),
              //     //             size: 35,
              //     //           ),
              //     //         ),
              //     //         SizedBox(height: 30),
              //     //         Text(
              //     //           "Home Visit",
              //     //           style: TextStyle(
              //     //             fontSize: 18,
              //     //             color: Colors.black,
              //     //             fontWeight: FontWeight.w500,
              //     //           ),
              //     //         ),
              //     //         SizedBox(height: 5),
              //     //         Text(
              //     //           "Call the doctor home",
              //     //           style: TextStyle(
              //     //             color: Colors.black54,
              //     //           ),
              //     //         ),
              //     //       ],
              //     //     ),
              //     //   ),
              //     // ),
              //   ],
              // ),
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
                  // Assurez-vous que le nom du champ correspond exactement à celui de votre base de données Firestore.
                  // De plus, utilisez `arrayContains` si le champ est un tableau ou `isEqualTo` si c'est une chaîne de caractères.
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
                        String adresse =
                            doctorData['adresse'] ?? ''; // Nom du médecin
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
                              boxShadow: [
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
                                if (Evaluation != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      Text(
                                        Evaluation.toString(),
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
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AllDoctorsScreen()));
                      },
                      child: Text('Tous les médecins'),
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


/*
StreamBuilder<QuerySnapshot>(
                stream: selectedSymptom == ''
                    ? FirebaseFirestore.instance
                        .collection('doctors')
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('doctors')
                        .where('Specialite', isEqualTo: selectedSymptom)
                        .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  return Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        final doctorData = document.data() as Map<String,
                            dynamic>; // Convertir en Map<String, dynamic>
                        if (doctorData != null) {
                          // Vérifiez si les données du médecin ne sont pas nulles
                          final doctorImg = doctorData['Image'] ??
                              ''; // Assurez-vous de gérer les valeurs null
                          final doctorName = doctorData['Nom'] ??
                              ''; // Assurez-vous de gérer les valeurs null
                          final rating = doctorData['Evaluation'] ?? '';
                          // Assurez-vous de gérer les valeurs null

                          // Utilisez les données du médecin ici
                          return InkWell(
                            onTap: () async {
                              List<Map<String, dynamic>> allDoctors =
                                  await _getAllDoctors();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentScreen(
                                    doctorId: document.id,
                                    doctorImg: doctorImg,
                                    doctorName: doctorName,
                                    rating: rating,
                                    allDoctors: allDoctors,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                  if (rating != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        Text(
                                          rating.toString(),
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
                        } else {
                          return SizedBox(); // Retourne un widget vide si les données sont nulles
                        }
                      }).toList(),
                    ),
                  );
                },
              ),


 */