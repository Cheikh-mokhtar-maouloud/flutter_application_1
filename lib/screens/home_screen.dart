import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Liste/ListeHome.dart';
import 'package:flutter_application_1/screens/appointment_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';

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

Future<String> _getUserName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    if (user.providerData
        .any((provider) => provider.providerId == "google.com")) {
      return user.displayName ?? "";
    } else {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;
      return userData["name"] as String;
    }
  }
  return "";
}

String extractFirstWord(String fullName) {
  List<String> words = fullName.split(' ');
  return words.isNotEmpty ? words[0] : '';
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> selectedDoctors = [];
  late Future<DocumentSnapshot> _doctorFuture;

  void filterDoctorsBySymptom(String symptom) {
    setState(() {
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
                              "Hello $firstName",
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingScreen(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage("images/doctor1.jpg"),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF7165D6),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Color(0xFF7165D6),
                              size: 35,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            "Clinic Visit",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Make an appointment",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFF0EEFA),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.home_filled,
                              color: Color(0xFF7165D6),
                              size: 35,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            "Home Visit",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Call the doctor home",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
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
                            hintText: 'What are your symptoms?',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {},
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
                  "Doctors",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
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
                        final doctorData =
                            document.data() as Map<String, dynamic>;
                        final doctorImg = doctorData['Image'];
                        final doctorName = doctorData['Nom'];
                        final rating = doctorData['Evaluation'];

                        return InkWell(
                          onTap: () {
                            // Ajoutez ici la navigation vers l'écran de rendez-vous
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
                                if (rating != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
