import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/ordonence.dart';
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
  String _patientName = 'Loading...'; // Valeur par défaut pour le nom
  String _patientImageUrl = 'default_image_url_here';
  bool _isLoaded = false;
  bool _isDoctor = true;
  late final String _conversationId;

  @override
  void initState() {
    super.initState();
    _doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
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

  Future<void> _sendMessage(
      {String? messageText, String? imageUrl, String? fileUrl}) async {
    if (messageText != null || imageUrl != null || fileUrl != null) {
      var messageData = {
        'senderId': _doctorId,
        'receiverId': _userId,
        'timestamp': Timestamp.now(),
        'conversationId': _conversationId,
        'messageText': messageText,
        'imageUrl': imageUrl,
        'fileUrl': fileUrl,
      };

      try {
        await FirebaseFirestore.instance
            .collection('messages')
            .add(messageData);
        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Stream<QuerySnapshot> _chatStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('conversationId', isEqualTo: _conversationId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message supprimé avec succès.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du message.')),
      );
    }
  }

  Future<void> _viewPDF(String url) async {
    var response = await http.get(Uri.parse(url));
    var documentDirectory = await getTemporaryDirectory();
    var filePathAndName = documentDirectory.path + '/tempPdf.pdf';
    File file = File(filePathAndName);
    file.writeAsBytesSync(response.bodyBytes);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFViewPage(filePath: filePathAndName)));
  }

  void _downloadFile(String url, String fileName) async {
    var response = await http.get(Uri.parse(url));
    var documentDirectory = await getTemporaryDirectory();
    File file = new File('${documentDirectory.path}/$fileName');
    file.writeAsBytesSync(response.bodyBytes);
    // Optionally, inform the user about the download completion or open the file.
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      String fileName =
          'chat_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);

      try {
        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();
        _sendMessage(imageUrl: downloadUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName =
          'chat_files/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);

      try {
        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();
        _sendMessage(fileUrl: downloadUrl);
      } catch (e) {
        print("Error uploading file: $e");
      }
    }
  }

  void _navigateToPrescriptionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionPage(doctorId: _doctorId),
      ),
    );
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
              onPressed: () {
                // Implement video call functionality
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: _chatStream(),
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

                      return GestureDetector(
                        onLongPress: () => _showDeleteDialog(messageId),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (message['imageUrl'] != null)
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                              title: Text('Image Preview')),
                                          body: Center(
                                            child: Image.network(
                                                message['imageUrl']),
                                          ),
                                        ),
                                      )),
                                  child: Image.network(message['imageUrl'],
                                      width: 150, height: 150),
                                ),
                              if (message['fileUrl'] != null)
                                InkWell(
                                  onTap: () => _viewPDF(message['fileUrl']),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.picture_as_pdf,
                                            size: 50, color: Colors.red),
                                        Text("Tap to view PDF")
                                      ],
                                    ),
                                  ),
                                ),
                              if (message['messageText'] != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blue[100]
                                        : Colors.grey[300],
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
                                  DateFormat('dd MMM, hh:mm a').format(
                                      (message['timestamp'] as Timestamp)
                                          .toDate()),
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
                    },
                  );
                }),
          ),
          _buildBottomSheet(),
        ],
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
                _deleteMessage(messageId);
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

  Container _buildBottomSheet() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Wrap(
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Send a photo'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text('Send a PDF'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickFile();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.medical_services),
                        title: Text('Rédiger une ordonnance'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPrescriptionPage();
                        },
                      ),
                    ],
                  );
                },
              );
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
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(messageText: _messageController.text.trim());
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
