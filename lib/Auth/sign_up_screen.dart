import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/Auth/login_screen.dart';
import 'package:flutter_application_1/Auth/service/authgoogle.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool passToggle = true;
  String email = "", password = "", name = "";
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _phoneTextController = TextEditingController();
  TextEditingController _addressTextController = TextEditingController();
  TextEditingController _descriptionTextController = TextEditingController();
  TextEditingController _birthdateTextController = TextEditingController();
  DateTime? selectedBirthDate;

  List<String> addresses = ["Nema", "NKTT", "NDB", "Rosso", "Kifa"];
  final _formkey = GlobalKey<FormState>();
  String? imageUrl;

  // Importez le package flutter_image_compress

  // Future<void> _uploadImage(XFile? image) async {
  //   if (image != null) {
  //     // Compressez l'image avant le téléchargement
  //     var compressedFile = await FlutterImageCompress.compressAndGetFile(
  //       image.path,
  //       '/tmp/${DateTime.now().millisecondsSinceEpoch}.jpg',
  //       quality: 50, // Ajustez la qualité comme nécessaire
  //     );

  //     if (compressedFile != null) {
  //       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //       Reference storageReference =
  //           FirebaseStorage.instance.ref().child('profile_images/$fileName');

  //       UploadTask uploadTask = storageReference.putFile(compressedFile);

  //       // Utilisez l'URL temporairement pour l'opération d'enregistrement
  //       uploadTask.then((TaskSnapshot taskSnapshot) async {
  //         String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //         _saveUserData(
  //             downloadUrl); // Méthode pour enregistrer les données utilisateur
  //       }).catchError((error) {
  //         print(error); // Gérer l'erreur
  //       });
  //     }
  //   }
  // }

  void _saveUserData(String imageUrl) async {
    // Ici, vous enregistrez les données utilisateur en utilisant l'URL de l'image
    // Cette fonction est appelée dès que l'URL de l'image est disponible
  }

// Dans la méthode registration, lancez _uploadImage sans attendre la fin du téléchargement
// Continuez avec l'enregistrement des autres données utilisateur en parallèle ou après selon votre logique d'application

  @override
  void dispose() {
    // Assurez-vous de disposer le controller
    _birthdateTextController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedBirthDate) {
      setState(() {
        selectedBirthDate = pickedDate;
        _birthdateTextController.text = DateFormat('yyyy-MM-dd')
            .format(pickedDate); // Afficher la date sélectionnée
      });
    }
  }

  bool _isAgeValid(DateTime birthDate) {
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return age >= 15; // Vérifiez si l'utilisateur a au moins 15 ans
  }

  Future<void> _showImageSourceSelection() async {
    final ImagePicker _picker = ImagePicker();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisissez la source de l\'image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Caméra'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      File file = File(image.path);
                      String fileName =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      Reference reference = FirebaseStorage.instance
                          .ref()
                          .child('profile_images/$fileName');
                      UploadTask uploadTask = reference.putFile(file);
                      TaskSnapshot storageTaskSnapshot =
                          await uploadTask.whenComplete(() {});
                      String downloadUrl =
                          await storageTaskSnapshot.ref.getDownloadURL();
                      imageUrl = downloadUrl;
                    }
                    // _uploadImage(image);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Galerie'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      File file = File(image.path);
                      String fileName =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      Reference reference = FirebaseStorage.instance
                          .ref()
                          .child('profile_images/$fileName');
                      UploadTask uploadTask = reference.putFile(file);
                      TaskSnapshot storageTaskSnapshot =
                          await uploadTask.whenComplete(() {});
                      String downloadUrl =
                          await storageTaskSnapshot.ref.getDownloadURL();
                      imageUrl = downloadUrl;
                    }
                    // _uploadImage(image);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleImageSelection(XFile? image) async {
    if (image != null) {
      File file = File(image.path);
      // Faites ce que vous voulez avec le fichier ici,
      // comme l'upload sur Firebase Storage ou autre...
    }
  }

  registration() async {
    String email = _emailTextController.text;
    String password = _passwordTextController.text;
    String name = _nameTextController.text;
    String phone = _phoneTextController.text;
    String address = _addressTextController.text;
    String description = _descriptionTextController.text;
    DateTime birthDate =
        DateTime.tryParse(_birthdateTextController.text) ?? DateTime.now();

    Duration ageDuration = DateTime.now().difference(birthDate);
    int age = (ageDuration.inDays / 365)
        .floor(); // Approximation à l'année la plus proche

    if (age < 15) {
      // Si l'utilisateur a moins de 15 ans, afficher une erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "You must be at least 15 years old to register.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
      return;
    }

    if (password.isNotEmpty &&
        _nameTextController.text.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        // Assurez-vous que imageUrl est correctement défini
        // et incluez-le dans les données utilisateur envoyées à Firestore
        FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "name": name,
          "email": email,
          "phone": phone,
          "Adress": address,
          "photoUrl":
              imageUrl, // Assurez-vous que l'URL de l'image est incluse ici
          "description": description,
          "birthDate": birthDate,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NavBarRoots()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Password Provided is too Weak",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Account Already exists",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Image.asset(
                    "images/doctors.png",
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Entre Name';
                      }
                      return null;
                    },
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      labelText: "Entrer Full Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                    onTap: () {
                      setState(() {
                        passToggle = !passToggle;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap:
                        _presentDatePicker, // Appel de la méthode pour ouvrir le DatePicker
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _birthdateTextController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          labelText: "Enter Date de naissance",
                          prefixIcon: Icon(Icons.cake),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Birthdate';
                          } else if (selectedBirthDate == null ||
                              !_isAgeValid(selectedBirthDate!)) {
                            return 'Vous devez avoir au moins 15 ans pour vous inscrire.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Entre Email';
                      }
                      return null;
                    },
                    controller: _emailTextController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      labelText: "Entrer Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    onTap: () {
                      setState(() {
                        passToggle = !passToggle;
                      });
                    },
                  ),
                ),

                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Entre Password';
                      }
                      return null;
                    },
                    controller: _passwordTextController,
                    obscureText: passToggle,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      labelText: "Entrer Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passToggle = !passToggle;
                          });
                        },
                        icon: Icon(
                          passToggle ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _phoneTextController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      labelText: "Entrer Phone Number",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Phone Number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _descriptionTextController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      labelText: "Entrer Description",
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLength: 135, // Limite la description à 120 caractères
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Description';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Entrer Adress",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    value: addresses.isNotEmpty ? addresses.first : null,
                    onChanged: (value) {
                      setState(() {
                        _addressTextController.text = value!;
                      });
                    },
                    items: addresses.map((address) {
                      return DropdownMenuItem<String>(
                        value: address,
                        child: Text(address),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 10),

                // Bouton pour ajouter la photo
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: _showImageSourceSelection,
                    child: Text('Ajouter une photo'),
                  ),
                ),

                SizedBox(height: 20),

                button(
                  title: "Create Account",
                  onTap: () async {
                    // Vérifier d'abord si l'image est téléchargée avec succès
                    // await _uploadImage();
                    // Ensuite, enregistrer l'utilisateur uniquement si l'image est téléchargée
                    if (imageUrl != null && _formkey.currentState!.validate()) {
                      registration();
                    } else {
                      // Afficher un message d'erreur si l'image n'est pas téléchargée
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "Please upload an image before registering.",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      );
                    }
                  },
                ),

                // SizedBox(height: 5),

                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => loginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7165D6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
