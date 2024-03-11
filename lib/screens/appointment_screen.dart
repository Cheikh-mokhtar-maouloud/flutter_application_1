import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Liste/Listeappointment.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
import 'package:flutter_application_1/screens/reservation.dart';

class AppointmentScreen extends StatelessWidget {
  final String doctorImg;
  final String doctorName;
  final double rating;
  List imgs = [
    "doctor1.jpg",
    "doctor2.jpg",
    "doctor3.jpg",
    "doctor4.jpg",
  ];

  Widget doctorAboutText(String name) {
    Map<String, String> doctorDescriptions = {
      'Dr. John Doe':
          "Dr. John Doe est un thérapeute expérimenté spécialisé dans la thérapie cognitivo-comportementale.",
      'Dr. Jane Smith':
          "Dr. Jane Smith est une psychiatre renommée connue pour ses soins attentionnés et son expertise dans les troubles anxieux.",
      'Dr. Michael Johnson':
          "Dr. Jane Smith est une psychiatre renommée connue pour ses soins attentionnés et son expertise dans les troubles anxieux.",
      'Dr. Emily Williams':
          "Dr. Jane Smith est une psychiatre renommée connue pour ses soins attentionnés et son expertise dans les troubles anxieux.",
      // Ajoutez d'autres médecins avec leurs descriptions ici
    };

    // Vérifier si le nom du médecin est dans la map des descriptions
    if (doctorDescriptions.containsKey(name)) {
      return Text(
        doctorDescriptions[name]!,
        style: TextStyle(fontSize: 16, color: Colors.black54),
      );
    } else {
      return Text(
        "Lorem Ipsum est simplement un texte fictif de l'industrie de l'impression et de la composition.",
        style: TextStyle(fontSize: 16, color: Colors.black54),
      );
    }
  }

  AppointmentScreen({
    required this.doctorImg,
    required this.doctorName,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7165D6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage("images/$doctorImg"),
                        ),
                        SizedBox(height: 15),
                        Text(
                          doctorName,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        // Text(
                        //   "Thérapeute",
                        //   style: TextStyle(
                        //     color: Colors.white60,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFF9F97E2),
                              child: Icon(
                                Icons.video_call,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        doctorName: doctorName,
                                        doctorImg: doctorImg),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                backgroundColor: Color(0xFF9F97E2),
                                child: Icon(
                                  CupertinoIcons.chat_bubble_text_fill,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 20,
                left: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "À propos du docteur",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  // Texte dynamique en fonction des informations du docteur
                  doctorAboutText(doctorName),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Avis",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.star, color: Colors.amber),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "(124)",
                        style: TextStyle(color: Colors.black54),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Voir tout",
                          style: TextStyle(
                            color: Color(0xFF7165D6),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.symmetric(vertical: 5),
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
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      AssetImage("images/${imgs[index]}"),
                                ),
                                title: Text(
                                  doctorName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text("Il y a 1 jour"),
                                trailing: Row(
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
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Merci beaucoup au Dr. Cher. Il est un excellent médecin et un professionnel.",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Emplacement",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0EEFA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Color(0xFF7165D6),
                        size: 30,
                      ),
                    ),
                    title: Text(
                      "New York, Centre Médical",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("Adresse du centre carafore"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Prix de consultation",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "\100 UMN ",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPage(),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Color(0xFF7165D6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Prendre un rendez-vous",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/screens/chat_screen.dart';

// class AppointmentScreen extends StatelessWidget {
//   final String doctorImg;
//   final String doctorName;
//   final double rating;

//   AppointmentScreen({
//     required this.doctorImg,
//     required this.doctorName,
//     required this.rating,
//   });

//   List imgs = [
//     "doctor1.jpg",
//     "doctor2.jpg",
//     "doctor3.jpg",
//     "doctor4.jpg",
//   ];

//   Widget doctorAboutText(String name) {
//     Map<String, Map<String, String>> doctorDetails = {
//       'Dr. John Doe': {
//         'description':
//             "Dr. John Doe est un thérapeute expérimenté spécialisé dans la thérapie cognitivo-comportementale.",
//         'address': "New York, Centre Médical - Adresse du centre carafore",
//       },
//       'Dr. Jane Smith': {
//         'description':
//             "Dr. Jane Smith est une psychiatre renommée connue pour ses soins attentionnés et son expertise dans les troubles anxieux.",
//         'address':
//             "Los Angeles, Centre de Psychiatrie - Adresse du centre lorem",
//       },
//       'Dr. Michael Johnson': {
//         'description':
//             "Dr. Michael Johnson est un médecin de famille passionné par la santé et le bien-être de ses patients.",
//         'address':
//             "Chicago, Centre de Santé Familiale - Adresse du centre ipsum",
//       },
//       'Dr. Emily Williams': {
//         'description':
//             "Dr. Emily Williams est une pédiatre dévouée spécialisée dans les soins des enfants et des nourrissons.",
//         'address':
//             "Houston, Centre Médical pour Enfants - Adresse du centre dolor",
//       },
//       // Add other doctors with their descriptions and addresses here
//     };

//     // Check if the doctor's name is in the map of details
//     if (doctorDetails.containsKey(name)) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "À propos du docteur",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//           ),
//           SizedBox(height: 5),
//           Text(
//             doctorDetails[name]!['description']!,
//             style: TextStyle(fontSize: 16, color: Colors.black54),
//           ),
//           SizedBox(height: 10),
//           Text(
//             "Emplacement",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//           ),
//           ListTile(
//             leading: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Color(0xFFF0EEFA),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.location_on,
//                 color: Color(0xFF7165D6),
//                 size: 30,
//               ),
//             ),
//             title: Text(
//               doctorDetails[name]!['address']!
//                   .split(', ')[0], // Extracting city
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Text(doctorDetails[name]!['address']!
//                 .split(', ')[1]), // Extracting address
//           ),
//         ],
//       );
//     } else {
//       return Text(
//         "Lorem Ipsum est simplement un texte fictif de l'industrie de l'impression et de la composition.",
//         style: TextStyle(fontSize: 16, color: Colors.black54),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF7165D6),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 50),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Stack(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         icon: Icon(
//                           Icons.arrow_back_ios_new,
//                           color: Colors.white,
//                           size: 25,
//                         ),
//                       ),
//                       Icon(
//                         Icons.more_vert,
//                         color: Colors.white,
//                         size: 28,
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         CircleAvatar(
//                           radius: 35,
//                           backgroundImage: AssetImage("images/$doctorImg"),
//                         ),
//                         SizedBox(height: 15),
//                         Text(
//                           doctorName,
//                           style: TextStyle(
//                             fontSize: 23,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         SizedBox(height: 15),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CircleAvatar(
//                               backgroundColor: Color(0xFF9F97E2),
//                               child: Icon(
//                                 Icons.video_call,
//                                 color: Colors.white,
//                                 size: 25,
//                               ),
//                             ),
//                             SizedBox(width: 20),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => ChatScreen(),
//                                   ),
//                                 );
//                               },
//                               child: CircleAvatar(
//                                 backgroundColor: Color(0xFF9F97E2),
//                                 child: Icon(
//                                   CupertinoIcons.chat_bubble_text_fill,
//                                   color: Colors.white,
//                                   size: 25,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Container(
//               height: MediaQuery.of(context).size.height * 0.6,
//               width: double.infinity,
//               padding: EdgeInsets.only(
//                 top: 20,
//                 left: 15,
//                 right: 15,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   doctorAboutText(doctorName),
//                   SizedBox(height: 10),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: 4,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           margin: EdgeInsets.symmetric(vertical: 10),
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 4,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               ListTile(
//                                 leading: CircleAvatar(
//                                   radius: 25,
//                                   backgroundImage:
//                                       AssetImage("images/${imgs[index]}"),
//                                 ),
//                                 title: Text(
//                                   doctorName,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 subtitle: Text("Il y a 1 jour"),
//                                 trailing: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.star,
//                                       color: Colors.amber,
//                                     ),
//                                     Text(
//                                       rating.toString(),
//                                       style: TextStyle(
//                                         color: Colors.black54,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: 5),
//                               Text(
//                                 "Merci beaucoup au Dr. Cher. Il est un excellent médecin et un professionnel.",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Prix de consultation",
//                   style: TextStyle(
//                     color: Colors.black54,
//                   ),
//                 ),
//                 Text(
//                   "\100 UMN ",
//                   style: TextStyle(
//                     color: Colors.black54,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 15),
//             InkWell(
//               onTap: () {},
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 18),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF7165D6),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Prendre un rendez-vous",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
