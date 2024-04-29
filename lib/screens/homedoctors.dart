// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_application_1/screens/chatdoctor.dart';

// class DoctorsScreen extends StatefulWidget {
//   @override
//   _DoctorsScreenState createState() => _DoctorsScreenState();
// }

// class _DoctorsScreenState extends State<DoctorsScreen> {
//   @override
//   String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Liste des Docteurs'), // 'const' added here
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//                 child: CircularProgressIndicator()); // 'const' added here
//           }
//           if (snapshot.hasError) {
//             return const Center(
//                 child:
//                     Text('Une erreur s\'est produite')); // 'const' added here
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//                 child: Text('Aucun docteur trouvé')); // 'const' added here
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               DocumentSnapshot doc = snapshot.data!.docs[index];
//               String doctorName = doc['Nom'];
//               String imageUrl = doc['Image'];

//               // ...

//               return Card(
//                 child: ListTile(
//                   leading: FadeInImage.assetNetwork(
//                     placeholder: 'images/doctors.png', // Local asset image
//                     image: imageUrl,
//                     fit: BoxFit.cover,
//                     width: 48.0,
//                     height: 48.0,
//                     imageErrorBuilder: (context, error, stackTrace) {
//                       // Providing a local image as fallback
//                       return const ImageIcon(
//                         AssetImage('images/doctors.png'),
//                         size: 48.0, // 'const' added here
//                       );
//                     },
//                   ),
//                   title: Text(doctorName),
//                   trailing: const Icon(Icons.arrow_forward),
//                   onTap: () async {
//                     // Obtenez l'ID de l'utilisateur à partir du message spécifique.
//                     // Vous devez avoir une référence au message spécifique ici.
//                     // Par exemple, vous pourriez avoir une liste des messages au médecin
//                     // et récupérer l'ID de l'utilisateur à partir de là.

//                     var messagesSnapshot = await FirebaseFirestore.instance
//                         .collection('messages')
//                         .where('receiverId', isEqualTo: doc.id) // ID du médecin
//                         .get();

//                     var userId = messagesSnapshot.docs.first.data()[
//                         'senderId']; // Cela prend le premier utilisateur qui a envoyé un message

//                     print('User ID: $userId');
//                     print('Doctor ID: ${doc.id}');

//                     // Naviguez vers la page de chat avec l'ID de l'utilisateur spécifique et l'ID du médecin
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Chatdoc(
//                           userId:
//                               userId, // ID de l'utilisateur qui a envoyé le message
//                           doctorId: doc.id, // ID du médecin sélectionné
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );

// // ...
//             },
//           );
//         },
//       ),
//     );
//   }
// }
