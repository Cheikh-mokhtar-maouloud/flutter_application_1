// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class SettingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Settings",
//             style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 30),
//           ListTile(
//             leading: CircleAvatar(
//               radius: 30,
//               backgroundImage: AssetImage("images/doctor1.jpg"),
//             ),
//             title: Text(
//               "Dear Programmer",
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 25,
//               ),
//             ),
//             subtitle: Text("Profile"),
//           ),
//           Divider(height: 50),
//           ListTile(
//             onTap: () {},
//             leading: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 CupertinoIcons.person,
//                 color: Colors.blue,
//                 size: 35,
//               ),
//             ),
//             title: Text(
//               "Profile",
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 20,
//               ),
//             ),
//             trailing: Icon(Icons.arrow_forward_ios_rounded),
//           ),
//           SizedBox(height: 20),
//           ListTile(
//             onTap: () {},
//             leading: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.deepPurple.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.notifications_none_outlined,
//                 color: Colors.deepPurple,
//                 size: 35,
//               ),
//             ),
//             title: Text(
//               "Notifications",
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 20,
//               ),
//             ),
//             trailing: Icon(Icons.arrow_forward_ios_rounded),
//           ),
//           SizedBox(height: 20),
//           ListTile(
//             onTap: () {},
//             leading: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.indigo.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.privacy_tip_outlined,
//                 color: Colors.indigo,
//                 size: 35,
//               ),
//             ),
//             title: Text(
//               "Privacy",
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 20,
//               ),
//             ),
//             trailing: Icon(Icons.arrow_forward_ios_rounded),
//           ),
//           SizedBox(height: 20),
//           ListTile(
//             onTap: () {},
//             leading: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.settings_suggest_outlined,
//                 color: Colors.green,
//                 size: 35,
//               ),
//             ),
//             title: Text(
//               "General",
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 20,
//               ),
//             ),
//             trailing: Icon(Icons.arrow_forward_ios_rounded),
//           ),
//           SizedBox(height: 20),
//           ListTile(
//             onTap: () {},
//             leading: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.info_outline_rounded,
//                 color: Colors.orange,
//                 size: 35,
//               ),
//             ),
//             title: Text(
//               "About Us",
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 20,
//               ),
//             ),
//             trailing: Icon(Icons.arrow_forward_ios_rounded),
//           ),
//           Divider(height: 40),
//           ListTile(
//             onTap: () {},
//             leading: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.redAccent.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.info_outline_rounded,
//                 color: Colors.redAccent,
//                 size: 35,
//               ),
//             ),
//             title: Text(
//               "Log Out",
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Auth/login_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/profil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SettingScreen(),
//     );
//   }
// }

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  File? _selectedImage;
  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Vérifiez si l'utilisateur s'est connecté avec Google
      if (user.providerData
          .any((provider) => provider.providerId == "google.com")) {
        // Si l'utilisateur s'est connecté avec Google, retournez son nom directement
        return user.displayName ?? "";
      } else {
        // Sinon, récupérez le nom de l'utilisateur à partir de Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover).image
                          : AssetImage("images/doctor1.jpg"),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.symmetric(horizontal: 120),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _pickImageFromcamera();
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            // _selectedImage != null
            //     ? Image.file(_selectedImage!)
            //     : const Text("please le select image"),
            Column(
              children: [
                Center(
                  child: FutureBuilder(
                    future: _getUserName(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          // Extraire le premier mot du nom de l'utilisateur
                          String firstName = extractFirstWord(snapshot.data!);
                          // Affiche le premier mot du nom de l'utilisateur
                          return Text(
                            " $firstName",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w300,
                            ),
                          );
                        } else {
                          // Affiche un indicateur de chargement si le nom de l'utilisateur n'est pas encore disponible
                          return CircularProgressIndicator();
                        }
                      } else {
                        // Affiche un indicateur de chargement tant que la connexion à Firestore est en cours
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ],
            ),
            Divider(height: 50),
            Expanded(
              child: ListView(
                children: [
                  _buildSettingTile(Icons.person, "Profile", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(),
                      ),
                    );
                  }),
                  SizedBox(height: 15),
                  _buildSettingTile(
                      Icons.notifications_none_outlined, "Notifications", () {
                    // Action to perform when "Notifications" is tapped
                  }),
                  SizedBox(height: 15),
                  _buildSettingTile(Icons.privacy_tip_outlined, "Privacy", () {
                    // Action to perform when "Privacy" is tapped
                  }),
                  SizedBox(height: 15),
                  _buildSettingTile(Icons.settings_suggest_outlined, "General",
                      () {
                    // Action to perform when "General" is tapped
                  }),
                  SizedBox(height: 15),
                  _buildSettingTile(Icons.info_outline_rounded, "About Us", () {
                    // Action to perform when "About Us" is tapped
                  }),
                ],
              ),
            ),
            Divider(height: 40),
            ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut().then((value) {
                  print("Signed out");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => loginScreen(),
                    ),
                  );
                });
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.redAccent,
                  size: 35,
                ),
              ),
              title: Text(
                "Log Out",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 32,
            ),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;
    {}
    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }

  Future<void> _pickImageFromcamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return;
    {}
    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }
}
