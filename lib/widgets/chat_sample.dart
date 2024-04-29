import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatSample extends StatefulWidget {
  @override
  _ChatSampleState createState() => _ChatSampleState();
}

class _ChatSampleState extends State<ChatSample> {
  TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Text(
                  _messages[index],
                  style: TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(message);
        _messageController.clear();
      });

      // Récupérez l'ID de l'utilisateur connecté (callerId)
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Récupérez l'ID du médecin avec lequel l'utilisateur communique
      String doctorId =
          'ID_DU_MEDECIN'; // Remplacez cela par l'ID du médecin approprié

      // Ajoutez le message à Firestore
      FirebaseFirestore.instance.collection('messages').add({
        'userId': userId,
        'doctorId': doctorId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        print('Message envoyé avec succès');
      }).catchError((error) {
        print('Erreur lors de l\'envoi du message : $error');
      });
    }
  }
}
