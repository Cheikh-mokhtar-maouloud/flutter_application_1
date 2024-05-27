import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Auth/login_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/profil.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late Future<String> _userNameFuture;
  late Future<String> _userImageUrlFuture;
  File? _selectedImage;
  late Future<Map<String, dynamic>> _userProfileFuture;
  bool isLoading = true;
  bool _notificationsEnabled = true;

  Future<void> _loadNotificationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = value;
    });
    await prefs.setBool('notifications_enabled', value);
  }

  @override
  void initState() {
    super.initState();
    // Initialisez `_doctorFuture` ici
    _userNameFuture = _getUserName();
    _userImageUrlFuture = _getUserImageUrl();
    _userProfileFuture = _getUserProfileData();
    _initializeUserDetails();
    _loadNotificationPreference();
  }

  Future<void> _initializeUserDetails() async {
    try {
      _userNameFuture = _getUserName();
      _userImageUrlFuture = _getUserImageUrl();
      _userProfileFuture = _getUserProfileData();
      await Future.wait(
          [_userNameFuture, _userImageUrlFuture, _userProfileFuture]);
      if (!mounted) return;
      setState(() {
        isLoading = false; // Chargement terminé
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading =
            false; // Assurez-vous de stopper le chargement en cas d'erreur
      });
      // Gérer l'exception
    }
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    print("Tentative de sélection d'une image...");

    final XFile? returnedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      print("Image sélectionnée: ${returnedImage.path}");

      setState(() {
        _selectedImage = File(returnedImage.path);
      });

      // Continue avec le téléchargement et la mise à jour de l'image
      await _uploadAndSaveImage();
    } else {
      print("Aucune image sélectionnée pour le téléchargement.");
    }
  }

  Future<void> _uploadAndSaveImage() async {
    if (_selectedImage == null) {
      print("Aucune image sélectionnée pour le téléchargement");
      return;
    }

    // Assurez-vous d'avoir une instance FirebaseStorage pour le téléchargement
    final firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    // Obtenir l'UID de l'utilisateur pour créer un chemin de fichier unique
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    // Créer un chemin de fichier unique pour l'image en utilisant l'UID et le timestamp
    final String filePath =
        'user_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Tenter de télécharger l'image sélectionnée dans Firebase Storage
    try {
      // Commencer le téléchargement
      await storage.ref(filePath).putFile(_selectedImage!);

      // Après le téléchargement, obtenir l'URL de téléchargement
      final String downloadUrl = await storage.ref(filePath).getDownloadURL();

      // Mettre à jour l'URL de l'image dans Firestore à l'emplacement du profil de l'utilisateur
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'photoUrl': downloadUrl,
      });

      // Mise à jour de l'UI pour afficher la nouvelle image avec setState si nécessaire
      setState(() {
        _userImageUrlFuture = Future.value(
            downloadUrl); // Mettre à jour l'URL de l'image dans l'interface utilisateur
      });
    } catch (e) {
      print("Erreur lors du téléchargement de l'image: $e");
      // Ici, vous pouvez gérer l'erreur et informer l'utilisateur - par exemple, afficher un snackbar
    }
  }

  Future<Map<String, dynamic>> _getUserProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        // Handle the case where the document does not exist or contains no data
        return {};
      }
    }
    throw Exception('User not logged in');
  }

  Future<String> _getUserImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData["photoUrl"] ?? "";
      }
    }
    return "";
  }

  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if the user signed in with Google
      if (user.providerData
          .any((provider) => provider.providerId == "google.com")) {
        // If the user signed in with Google, return their name directly
        return user.displayName ?? "";
      } else {
        // Otherwise, retrieve the user's name from Firestore
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data() as Map<String, dynamic>;
          return userData["name"] ?? "";
        } else {
          // Handle the case where the document does not exist or contains no data
          return "";
        }
      }
    }
    return "";
  }

  void _attemptDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Retourne un AlertDialog
        return AlertDialog(
          title: Text('Supprimer le compte'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer votre compte ? Toutes les données associées seront perdues.'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => loginScreen()),
                );
                await _deleteUserAccount();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisir la langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Français'),
                onTap: () {
                  // Ici, définissez la logique pour changer la langue en français
                  Navigator.of(context).pop(); // Fermez la boîte de dialogue
                },
              ),
              ListTile(
                title: Text('English'),
                onTap: () {
                  // Ici, définissez la logique pour changer la langue en anglais
                  Navigator.of(context).pop(); // Fermez la boîte de dialogue
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteUserAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Supprimez les réservations de l'utilisateur
        await FirebaseFirestore.instance
            .collection('reservations')
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        // Supprimez les messages de chat de l'utilisateur
        await FirebaseFirestore.instance
            .collection('messages')
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        // Supprimez le profil de l'utilisateur
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Enfin, supprimez le compte utilisateur
        await user.delete();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => loginScreen()),
          ModalRoute.withName('/'),
        );
      }
    } catch (e) {
      print(
          e); // Vous pourriez vouloir afficher un message d'erreur à l'utilisateur
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètre"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      NavBarRoots()), // Remplacez HomeScreen par l'écran d'accueil de votre app
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Affiche un indicateur de chargement
          : buildUserSettings(), // Construire l'interface utilisateur des paramètres
    );
  }

  @override
  Widget buildUserSettings() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            // Appel de la fonction pour mettre à jour l'image
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Center(
                  child: FutureBuilder<String>(
                    future: _userImageUrlFuture,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return CircleAvatar(
                            key:
                                UniqueKey(), // Force le rafraîchissement de l'image
                            radius: 60,
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage("images/doctor1.jpg"),
                          );
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                InkWell(
                  onTap:
                      _updateProfileImage, // Appel de la fonction pour sélectionner l'image
                  child: Container(
                    height: 30,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Color(0xFF7165D6),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.camera_alt, size: 20, color: Colors.white),
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
            child: Column(
              children: [
                _buildSettingTile(Icons.person, "Profile", () async {
                  try {
                    final userProfileData = await _userProfileFuture;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                            name: userProfileData['name'] ?? 'No Name',
                            phone: userProfileData['phone'] ?? 'No Phone',
                            address: userProfileData['Adress'] ??
                                'No Address', // Make sure the key matches your Firestore field
                            email: userProfileData['email'] ?? 'No Email',
                            description: userProfileData['descrition'] ??
                                'No description'),
                      ),
                    );
                  } catch (e) {
                    // Handle the error or inform the user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }),
                SizedBox(height: 15),
                _buildSettingTile(
                  Icons.notifications_none_outlined,
                  "Notifications",
                  () {},
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                ),
                SizedBox(height: 4),
                _buildSettingTile(
                    Icons.language, "Changement de langue", _changeLanguage),

                SizedBox(height: 4),
                _buildSettingTile(Icons.delete_forever, "Delete Account",
                    _attemptDeleteAccount),

                // SizedBox(height: 15),
                // _buildSettingTile(Icons.settings_suggest_outlined, "General",
                //     () {
                //   // Action to perform when "General" is tapped
                // }),
                // SizedBox(height: 15),
                // _buildSettingTile(Icons.info_outline_rounded, "About Us", () {
                //   // Action to perform when "About Us" is tapped
                // }),
              ],
            ),
          ),

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
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
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
    );
  }

  Widget _buildSettingTile(IconData icon, String title, Function()? onTap,
      {Widget? trailing}) {
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
              color: Color(0xFF7165D6),
              size: 32,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('fr', 'FR'); // Locale initiale

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale))
      return; // Vérifie si la locale est supportée
    _locale = locale;
    notifyListeners();
  }
}

class L10n {
  static final all = [
    const Locale('en', 'US'),
    const Locale('fr', 'FR'),
  ];
}
