import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/chatdoctor.dart';
import 'package:flutter_application_1/screens/logindoctor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreendoc extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreendoc> {
  late File _image;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  // final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _addressController =
      TextEditingController(); // Nouveau champ pour l'adresse
  final TextEditingController _licenseNumberController =
      TextEditingController();
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
  List<String> filteredSymptoms = [];
  TextEditingController _symptomsSearchController = TextEditingController();
  bool isSymptomsListVisible = false;
  bool isLoading = false;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : _image;
    });
  }

  // void showSymptomsSearch() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: symptoms
  //             .where((symptom) => symptom
  //                 .toLowerCase()
  //                 .contains(_symptomsSearchController.text.toLowerCase()))
  //             .map((filteredSymptom) => ListTile(
  //                   title: Text(filteredSymptom),
  //                   onTap: () {
  //                     print(
  //                         filteredSymptom); // ou toute autre logique nécessaire
  //                     Navigator.of(context).pop();
  //                   },
  //                 ))
  //             .toList(),
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _image = File('your_default_image_path');
    filteredSymptoms = symptoms; // Initialise _image
  }

  void filterSymptoms(String query) {
    if (query.isNotEmpty) {
      List<String> filteredList = symptoms.where((symptom) {
        return symptom.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        filteredSymptoms = filteredList;
        isSymptomsListVisible = true; // Show the list when filtering
      });
    } else {
      setState(() {
        isSymptomsListVisible = false;
      });
    }
  }

  void selectSymptom(String selectedSymptom) {
    _symptomsSearchController.text = selectedSymptom;
    setState(() {
      isSymptomsListVisible = false; // Hide the list after selection
    });
  }

  void toggleSymptomsListVisibility() {
    setState(() {
      isSymptomsListVisible = !isSymptomsListVisible;
    });
  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true; // Indiquer que le processus de chargement a commencé
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String imageUrl = '';
      if (_image.path != 'your_default_image_path') {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(userCredential.user!.uid + '.jpg');
        await storageReference.putFile(_image);
        imageUrl = await storageReference.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text,
        'Nom': _nameController.text,
        'NumeroTel': _phoneNumberController.text,
        // 'Specialite': _specialtyController.text,
        'description': _descriptionController.text,
        'symptoms': _symptomsSearchController.text,
        'Image': imageUrl,
        'adresse': _addressController.text, // Enregistre l'adresse
      });

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Chatdoc(
                    userId: '',
                    doctorId: '',
                  )));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print('Erreur d\'inscription: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    // _specialtyController.dispose();
    _descriptionController.dispose();
    _symptomsController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _symptomsSearchController.dispose();
    // Disposez du contrôleur
    super.dispose();
  }

  Future<void> uploadDocument() async {
    final pickedFile = await picker.getImage(
        source: ImageSource
            .gallery); // Utiliser getImage pour des images, envisagez pickFile pour d'autres types de documents si nécessaire

    if (pickedFile != null) {
      File document = File(pickedFile.path);

      // Télécharger le document sur Firebase Storage
      String userId = FirebaseAuth.instance.currentUser!.uid;
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('professional_ids')
          .child(userId + '.jpg');

      await storageReference.putFile(document);
      String documentUrl = await storageReference.getDownloadURL();

      // Sauvegarder l'URL du document dans Firestore ou toute autre base de données que vous utilisez
      await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .doc(userId)
          .update({
        'professionalIdUrl': documentUrl,
      });

      // Vous pouvez afficher un message de confirmation ou mettre à jour l'interface utilisateur ici
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50, // La taille du cercle
                    backgroundColor: Colors
                        .transparent, // Optionnel: Couleur de fond si l'image ne couvre pas tout le cercle
                    child: _image.path != 'your_default_image_path'
                        ? Image.file(
                            _image,
                            height: 100.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Placeholder(
                            fallbackHeight: 100.0,
                            fallbackWidth: double
                                .infinity), // Remplacez 'assets/your_default_image.png' par votre image par défaut dans les assets
                  ),
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                  ),
                  onPressed: getImage,
                  child: Text('Pick Image'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phone Number',
                    ),
                  ),
                ),
                // Ajouter un champ pour le numéro de licence

                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: TextField(
                //     controller: _specialtyController,
                //     decoration: InputDecoration(
                //       border: OutlineInputBorder(),
                //       labelText: 'Specialty',
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                    ),
                  ),
                ),

                GestureDetector(
                  onTap:
                      toggleSymptomsListVisibility, // Toggle list visibility on tap
                  child: AbsorbPointer(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _symptomsSearchController,
                        decoration: InputDecoration(
                          labelText: 'Search Symptoms',
                          suffixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: filterSymptoms,
                      ),
                    ),
                  ),
                ),
                if (isSymptomsListVisible) // Conditional rendering of the list
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredSymptoms.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredSymptoms[index]),
                          onTap: () => selectSymptom(filteredSymptoms[index]),
                        );
                      },
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Address',
                    ),
                  ),
                ),

//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 controller:
//                     _licenseNumberController, // Assurez-vous d'initialiser ce contrôleur dans votre état
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'License Number',
//                 ),
//               ),
//             ),

// // Ajouter un bouton pour le téléchargement de document
//             ElevatedButton(
//               onPressed:
//                   uploadDocument, // Cette fonction sera définie pour gérer le téléchargement
//               child: Text('Upload Professional ID'),
//             ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color
                      ),
                      onPressed: signUp,
                      child: Text('Sign Up'),
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: Text('Login'),
                    ),
                  ],
                )
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
