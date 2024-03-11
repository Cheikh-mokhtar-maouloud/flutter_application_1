// import 'dart:convert';
// import 'dart:developer';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/Api/Api.dart';
// import 'package:flutter_application_1/screens/chatUser.dart';
// import 'package:flutter_application_1/widgets/chat_sample.dart';
// import 'package:flutter_application_1/screens/chat_screen.dart';

// class MessagesScreen extends StatefulWidget {
//   final ChatUser user;
//   const MessagesScreen({super.key, required this.user});

//   @override
//   State<MessagesScreen> createState() => _MessagesScreenState();
// }

// class _MessagesScreenState extends State<MessagesScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         elevation: 0.5,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: InkWell(
//           onTap: () {},
//           child: ListTile(
//               // leading: const CircleAvatar(
//               //   child: Icon(CupertinoIcons.person),
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(50),
//                 child: CachedNetworkImage(
//                   width: 100,
//                   height: 50,
//                   imageUrl: "http://via.placeholder.com/350x150",
//                   // placeholder: (context, url) => CircularProgressIndicator(),
//                   errorWidget: (context, url, error) =>
//                       const CircleAvatar(child: Icon(CupertinoIcons.person)),
//                 ),
//               ),
//               title: Text(widget.user.name),
//               subtitle: Text(widget.user.about, maxLines: 1),
//               trailing: Container(
//                 width: 10,
//                 height: 10,
//                 decoration: BoxDecoration(
//                     color: Colors.greenAccent.shade400,
//                     borderRadius: BorderRadius.circular(5)),
//               )
//               // trailing: const Text(
//               //   "12:00 PM",
//               //   style: TextStyle(
//               //     color: Colors.black45,
//               //   ),
//               // ),
//               ),
//         ));
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/widgets/chat_sample.dart';
// import 'package:flutter_application_1/screens/chat_screen.dart';

// class MessagesScreen extends StatelessWidget {
//   List<Map<String, String>> doctors = [
//     {"name": "Dr. John", "img": "doctor1.jpg"},
//     {"name": "Dr. Emily", "img": "doctor2.jpg"},
//     {"name": "Dr. Mike", "img": "doctor3.jpg"},
//     {"name": "Dr. Sarah", "img": "doctor4.jpg"},
//   ];

//   // Fonction pour naviguer vers la page de chat avec un médecin spécifique
//   void navigateToChat(
//       BuildContext context, String doctorName, String doctorImg) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(
//           doctorName: doctorName,
//           doctorImg: doctorImg,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Messages"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 "Messages",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 15),
//               child: Material(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 15),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             hintText: "Search",
//                             border: InputBorder.none,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Icon(
//                         Icons.search,
//                         color: Color(0xFF113953),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             SizedBox(
//               height: 120,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: doctors.length,
//                 shrinkWrap: true,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {
//                       // Lorsqu'un médecin est sélectionné, naviguer vers le chat avec ce médecin
//                       navigateToChat(context, doctors[index]["name"]!,
//                           doctors[index]["img"]!);
//                     },
//                     child: Container(
//                       margin: EdgeInsets.symmetric(horizontal: 12),
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Stack(
//                         children: [
//                           Center(
//                             child: Container(
//                               height: 80,
//                               width: 80,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 image: DecorationImage(
//                                   image: AssetImage(
//                                       "images/${doctors[index]["img"]}"),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             top: 2,
//                             right: 2,
//                             child: Container(
//                               height: 16,
//                               width: 16,
//                               decoration: BoxDecoration(
//                                 color: Colors.green,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 20),
//             ListView.builder(
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: doctors.length,
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   onTap: () {
//                     // Lorsqu'un élément de la liste est tapé, naviguer vers le chat avec ce médecin
//                     navigateToChat(context, doctors[index]["name"]!,
//                         doctors[index]["img"]!);
//                   },
//                   leading: CircleAvatar(
//                     radius: 30,
//                     backgroundImage:
//                         AssetImage("images/${doctors[index]["img"]}"),
//                   ),
//                   title: Text(
//                     doctors[index]["name"]!,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   subtitle: Text(
//                     "Hello, Doctor, are you there?",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black54,
//                     ),
//                   ),
//                   trailing: Text(
//                     "12:30",
//                     style: TextStyle(fontSize: 12, color: Colors.black54),
//                   ),
//                 );
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/chat_sample.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  List imgs = [
    "doctor1.jpg",
    "doctor2.jpg",
    "doctor3.jpg",
    "doctor4.jpg",
    "doctor1.jpg",
    "doctor2.jpg",
  ];

  // Fonction pour naviguer vers la page de chat avec un médecin spécifique
  void navigateToChat(
      BuildContext context, String doctorName, String doctorImg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          doctorName: doctorName,
          doctorImg: doctorImg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Messages",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Material(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: "Search",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.search,
                        color: Color(0xFF113953),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Lorsqu'un médecin est sélectionné, naviguer vers le chat avec ce médecin
                      navigateToChat(context, "Dr. ${index + 1}", imgs[index]);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage("images/${imgs[index]}"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    // Lorsqu'un élément de la liste est tapé, naviguer vers le chat avec ce médecin
                    navigateToChat(context, "Dr. ${index + 1}", imgs[index]);
                  },
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("images/${imgs[index]}"),
                  ),
                  title: Text(
                    "Dr. ${index + 1}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Hello, Doctor, are you there?",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  trailing: Text(
                    "12:30",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
