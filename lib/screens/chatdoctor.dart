import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/Api/firebase_api.dart';
import 'package:flutter_application_1/components/dialogs.dart';
import 'package:flutter_application_1/functions/functions.dart';
import 'package:flutter_application_1/screens/ordonence.dart';
import 'package:flutter_application_1/screens/video_call.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Chatdoc extends StatefulWidget {
  final String userId;
  final String doctorId;

  Chatdoc({
    required this.userId,
    required this.doctorId,
  });

  @override
  _ChatdocState createState() => _ChatdocState();
}

class _ChatdocState extends State<Chatdoc> {
  final TextEditingController _messageController = TextEditingController();
  late final String _doctorId;
  late final String _userId;

  late String _doctorName = 'Mohamed'; // Valeur par défaut pour le nom
  String _patientName = 'Loading...'; // Valeur par défaut pour le nom
  String _patientImageUrl = 'default_image_url_here';
  bool _isLoaded = false;
  bool _isDoctor = true;
  late final String _conversationId;

  @override
  void initState() {
    super.initState();
    _doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _doctorName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    _userId = widget.userId;
    _conversationId = _generateConversationId();
    _isDoctor = true;
    _fetchPatientDetails();
  }

  String _generateConversationId() {
    List<String> ids = [_userId, _doctorId];
    ids.sort();
    return ids.join('_');
  }

  void _fetchPatientDetails() async {
    // Fetch patient details from Firestore
    var patientDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    setState(() {
      _patientName = patientDoc.data()?['name'] ??
          'Patient'; // Replace 'name' with your patient name field
      _patientImageUrl =
          patientDoc.data()?['photoUrl'] ?? 'default_image_url_if_none';
      _isLoaded = true; // Set to true once data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoaded
            ? Row(
                // Check if data is loaded
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_patientImageUrl),
                  ),
                  SizedBox(width: 10),
                  Text(_patientName),
                ],
              )
            : CircularProgressIndicator(), // Show loading indicator if not loaded
        actions: [
          if (_isLoaded)
            IconButton(
              // Only show if loaded
              icon: Icon(Icons.video_call),
              onPressed: () => FunctionsSDoctor.initiateVideoCall(
                context,
                _userId,
                _patientName,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseApi.chatStream(_conversationId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message =
                          messages[index].data() as Map<String, dynamic>;
                      bool isMe = message['senderId'] == _doctorId;
                      String messageId = messages[index].id;
                      log(messageId);

                      return ListviewBuilder(messageId, isMe, message, context);
                    },
                  );
                }),
          ),
          _buildBottomSheet(_doctorId, _doctorName),
        ],
      ),
    );
  }

  GestureDetector ListviewBuilder(String messageId, bool isMe,
      Map<String, dynamic> message, BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(messageId),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message['imageUrl'] != null)
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: Text('Image Preview')),
                        body: Center(
                          child: Image.network(message['imageUrl']),
                        ),
                      ),
                    )),
                child:
                    Image.network(message['imageUrl'], width: 150, height: 150),
              ),
            if (message['fileUrl'] != null)
              InkWell(
                onTap: () =>
                    FunctionsSDoctor.viewPDF(message['fileUrl'], context),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                      Text("Tap to view PDF")
                    ],
                  ),
                ),
              ),
            if (message['messageText'] != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message['messageText'],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                DateFormat('dd MMM, hh:mm a')
                    .format((message['timestamp'] as Timestamp).toDate()),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer le message'),
          content: Text('Voulez-vous vraiment supprimer ce message?'),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseApi.deleteMessage(messageId, context);
                Navigator.of(context).pop();
              },
              child: Text('Supprimer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Container _buildBottomSheet(String doctorid, dotor_name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              modelsheet(context, doctorid, _userId, _conversationId);
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Color(0xFF7165D6),
            onPressed: () async {
              DocumentSnapshot<Map<String, dynamic>> userSnapshot =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_userId)
                      .get();
              DocumentSnapshot<Map<String, dynamic>> doct =
                  await FirebaseFirestore.instance
                      .collection('doctors')
                      .doc(_doctorId)
                      .get();
              String user_device_token = userSnapshot.data()!['deviceId'];
              String doctname = doct.data()!['Nom'];
              log(_doctorName);
              if (_messageController.text.trim().isNotEmpty) {
                FunctionsSDoctor.sendMessage(
                    _messageController.text.trim(),
                    null,
                    null,
                    _doctorId,
                    _userId,
                    _conversationId,
                    _messageController,
                    true);
                FirebaseApi.sendAndroidNotification(
                    _messageController.text, doctname, "55", user_device_token);
              }
            },
          ),
        ],
      ),
    );
  }
}

class PDFViewPage extends StatelessWidget {
  final String filePath;

  PDFViewPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Document"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // Implement download functionality
            },
          ),
        ],
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
