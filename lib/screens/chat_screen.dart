// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/widgets/chat_sample.dart';

// class ChatScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF7165D6),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 25,
//               backgroundImage: AssetImage("images/doctor1.jpg"),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 "Dr. Doctor Name",
//                 style: TextStyle(color: Colors.white),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.call),
//             iconSize: 26,
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.video_call),
//             iconSize: 30,
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.more_vert),
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(15),
//         itemCount: 7,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: EdgeInsets.only(bottom: 15),
//             child: ChatSample(),
//           );
//         },
//       ),
//       bottomSheet: Container(
//         height: 65,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 2,
//               blurRadius: 10,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.add),
//               iconSize: 30,
//             ),
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.emoji_emotions_outlined),
//               iconSize: 30,
//               color: Colors.amber,
//             ),
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 child: TextFormField(
//                   decoration: InputDecoration(
//                     hintText: "Type something",
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.send),
//               iconSize: 30,
//               color: Color(0xFF7165D6),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/chat_sample.dart';

class ChatScreen extends StatelessWidget {
  final String doctorName;
  final String doctorImg;

  ChatScreen({
    required this.doctorName,
    required this.doctorImg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7165D6),
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage("images/$doctorImg"),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                doctorName,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(Icons.call),
          //   iconSize: 26,
          // ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.video_call),
            iconSize: 30,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: ChatSample(),
          );
        },
      ),
      bottomSheet: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.add),
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.emoji_emotions_outlined),
              iconSize: 30,
              color: Colors.amber,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Type something",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.send),
              iconSize: 30,
              color: Color(0xFF7165D6),
            ),
          ],
        ),
      ),
    );
  }
}
