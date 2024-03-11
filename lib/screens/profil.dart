// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/Api/Api.dart';
// import 'package:flutter_application_1/screens/chatUser.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class profil extends StatefulWidget {
//   final ChatUser user;
//   const profil({super.key, required this.user});

//   @override
//   State<profil> createState() => _profilState();
// }

// class _profilState extends State<profil> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile Screnn"),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: FloatingActionButton(
//           onPressed: () async {
//             await Apis.auth.signOut();
//             await GoogleSignIn().signOut();
//           },
//           child: const Icon(Icons.add_comment_rounded),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            itemProfile('Name', 'Ahad Hashmi', CupertinoIcons.person),
            const SizedBox(height: 10),
            itemProfile('Phone', '03107085816', CupertinoIcons.phone),
            const SizedBox(height: 10),
            itemProfile(
                'Address', 'abc address, xyz city', CupertinoIcons.location),
            const SizedBox(height: 10),
            itemProfile(
                'Email', 'ahadhashmideveloper@gmail.com', CupertinoIcons.mail),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text('Edit Profile')),
            )
          ],
        ),
      ),
    );
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 5),
                color: Colors.blue.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.blue.shade400),
        tileColor: Colors.white,
      ),
    );
  }
}
