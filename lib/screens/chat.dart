// import 'dart:convert';
// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/Api/Api.dart';
// import 'package:flutter_application_1/screens/chatUser.dart';
// import 'package:flutter_application_1/screens/messages_screen.dart';
// import 'package:flutter_application_1/screens/profil.dart';
// import 'package:flutter_application_1/widgets/chat_sample.dart';
// import 'package:flutter_application_1/screens/chat_screen.dart';

// class chatscrennn extends StatelessWidget {
//   @override
//   List<ChatUser> list = [];
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Messages"),
//         actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
//           IconButton(
//             onPressed: () {
//               if (list.isNotEmpty) {
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(builder: (_) => profil(user: list[0])),
//                 // );
//               } else {
//                 // Gérez le cas où la liste est vide ou ne contient pas assez d'éléments.
//                 // Vous pouvez afficher un message d'erreur ou prendre d'autres mesures appropriées.
//               }
//             },
//             icon: const Icon(Icons.more_vert),
//           )
//         ],
//       ),
//       body: StreamBuilder(
//         stream: Apis.firestore
//             .collection('message')
//             .snapshots(), // replace with your stream of doctors
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//             case ConnectionState.none:
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             case ConnectionState.active:
//             case ConnectionState.done:
//               var list = [];
//               if (snapshot.hasData) {
//                 final data = snapshot.data?.docs;
//                 list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
//                     [];
//               }
//               if (list.isNotEmpty) {
//                 return ListView.builder(
//                   itemCount: list.length,
//                   padding: EdgeInsets.only(top: 20),
//                   itemBuilder: (context, index) {
//                     return MessagesScreen(user: list[index]);
//                     // return Text('name: ${list[index]}');
//                   },
//                 );
//               } else {
//                 return const Center(
//                   child: Text(
//                     "No Correction Found",
//                     style: TextStyle(fontSize: 20),
//                   ),
//                 );
//               }
//           }
//         },
//       ),
//     );
//   }
// }
