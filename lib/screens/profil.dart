import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/editprofil.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String address;
  final String email;
  final String description;

  const ProfileScreen({
    Key? key,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.description,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _phone;
  late String _address;
  late String _email;
  String _description = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the user document from Firestore
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        // Update the state with the new user data
        setState(() {
          _name = userData['name'] ?? 'No name provided';
          _phone = userData['phone'] ?? 'No phone provided';
          _address = userData['Adress'] ??
              'No address provided'; // Note: Make sure the key matches your Firestore field.
          _email = userData['email'] ?? 'No email provided';
          _description = userData['description'] ?? 'No description provided';
        });
      } else {
        // Handle the case where the user document does not exist.
      }
    } else {
      // Handle the case where there is no logged-in user.
    }
  }

  // Call this method when you need to refresh the profile data.
  void _refreshProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          // Mise à jour de l'état avec les nouvelles données utilisateur
          _name = userData['name'] ?? 'No name provided';
          _phone = userData['phone'] ?? 'No phone provided';
          _address = userData['Adress'] ?? 'No address provided';
          _email = userData['email'] ?? 'No email provided';
          _description = userData['description'] ?? 'No description provided';
        });
      }
    }
  }

// Inside _ProfileScreenState in ProfileScreen
  void _navigateAndEditProfile(BuildContext context) async {
    // Await the result from the EditProfileScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: _name,
          phone: _phone,
          address: _address,

          description: _description,
          onProfileUpdated: _refreshProfile, // No longer needed
        ),
      ),
    );

    // Check if the result contains updated data
    if (result != null && result is Map<String, dynamic>) {
      // Update the state with the new data
      setState(() {
        _name = result['name'] ?? _name;
        _phone = result['phone'] ?? _phone;
        _address = result['Adress'] ?? _address;
        _email = result['email'] ?? _email;
        _description = result['description'] ?? _description;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Profile'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              children: [
                itemProfile('Name', widget.name, CupertinoIcons.person),
                const SizedBox(height: 10),
                itemProfile('Phone', widget.phone, CupertinoIcons.phone),
                const SizedBox(height: 10),
                itemProfile('Address', widget.address, CupertinoIcons.location),
                const SizedBox(height: 10),
                itemProfile('Email', widget.email, CupertinoIcons.mail),
                const SizedBox(height: 10),
                itemProfile(
                    'dossier médical',
                    _description ?? 'No description provided',
                    CupertinoIcons.decrease_indent),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateAndEditProfile(context),
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.blue.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
        tileColor: Colors.white,
      ),
    );
  }
}
