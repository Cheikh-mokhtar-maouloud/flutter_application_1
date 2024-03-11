// import 'dart:html';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class numb extends StatelessWidget {
//   final TextEditingController numberphone;
//   const numb({super.key, required this.numberphone});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: TextField(
//         controller: numberphone,
//         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           hintText: "$numberphone",
//           border: OutlineInputBorder(),
//           prefixIcon: Icon(Icons.phone),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class Numb extends StatelessWidget {
//   final TextEditingController numberphone;
//   final String hintText;

//   const Numb({
//     Key? key,
//     required this.numberphone,
//     required this.hintText,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: TextField(
//         controller: numberphone,
//         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           hintText: "$numberphone",
//           border: OutlineInputBorder(),
//           prefixIcon: Icon(Icons.phone),
//         ),
//       ),
//     );
//   }
// }
//
// Container number(
//     BuildContext context, String title, Function onPressed, bool passToggle) {
//   return Container(
//     child: Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: TextField(
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           labelText: "Enter Password",
//           prefixIcon: Icon(Icons.lock),
//           suffixIcon: IconButton(
//             onPressed: () {},
//             icon: Icon(
//               passToggle
//                   ? CupertinoIcons.eye_slash_fill
//                   : CupertinoIcons.eye_fill,
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }