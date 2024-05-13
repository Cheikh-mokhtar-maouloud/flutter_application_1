import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// import 'package:fluttertoast/fluttertoast.dart';

class ChatScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorImg;

  ChatScreen({
    required this.doctorId,
    required this.doctorName,
    required this.doctorImg,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String _doctorImg;
  late bool _hasReservation;
  late TextEditingController _messageController;
  late String _userId;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _doctorImg = widget.doctorImg;
    _hasReservation = false;
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _messageController = TextEditingController();
    _checkAndNavigate();
    _initConversation();
    _createOrGetConversation();
  }

  void _createOrGetConversation() {
    final ids = [_userId, widget.doctorId];
    ids.sort(); // Assurez-vous que l'ordre est cohérent.
    _conversationId = ids.join('_');
    setState(() {});
  }

  Future<void> _initConversation() async {
    // Exemple de création d'un identifiant de conversation unique basé sur les IDs de l'utilisateur et du docteur
    _conversationId = '${_userId}_${widget.doctorId}';
    // Vous pourriez vouloir vérifier dans votre base de données si cet ID existe déjà et agir en conséquence
    setState(() {});
  }

  Stream<QuerySnapshot> _chatStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('conversationId', isEqualTo: _conversationId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<bool> checkReservation(String userId, String doctorId) async {
    QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .where('doctorId', isEqualTo: doctorId)
        .get();

    return reservationSnapshot.docs.isNotEmpty;
  }

  Future<void> _uploadImageFile(File imageFile) async {
    String fileName =
        'chat_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);

    try {
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();
      _sendMessage(messageText: '', imageUrl: downloadUrl);
    } catch (e) {
      print("Erreur lors de l'upload de l'image: $e");
    }
  }

  Future<void> _checkAndNavigate() async {
    bool hasReservation = await _hasActiveReservation(_userId, widget.doctorId);
    print(_userId);
    print(widget.doctorId);
    if (!hasReservation) {
      // Si pas de réservation, on affiche une alerte puis on retourne à l'écran précédent après la fermeture de l'alerte.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible:
              false, // L'utilisateur doit appuyer sur le bouton pour fermer le dialogue.
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text(
                  'Vous devez avoir une réservation avec ce médecin pour accéder au chat.'),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme l'AlertDialog
                    Navigator.of(context).pop(); // Retourne à l'écran précédent
                  },
                ),
              ],
            );
          },
        );
      });
    } else {
      // S'il y a une réservation, on initialise le conversationId et on met à jour l'état pour afficher le chat.
      _initConversation();
      setState(() {
        _hasReservation = true;
      });
    }
  }

  // Reste du code ...

  Future<bool> _hasActiveReservation(String userId, String doctorId) async {
    QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .where('doctorId', isEqualTo: doctorId)
        // You might also want to check if the reservation is still active based on the date or status
        .get();

    // If any documents are found, return true to indicate that an active reservation exists
    if (reservationSnapshot.docs.isNotEmpty) {
      return true;
    }

    // If no documents are found, return false to indicate that no active reservation exists
    return false;
  }

  Future<void> _sendMessage({
    String? messageText,
    String? imageUrl,
    String? fileUrl,
  }) async {
    if (_conversationId == null) return;

    // Avant d'envoyer le message, vérifiez si l'utilisateur a une réservation
    // et si la date de la réservation est arrivée.
    bool hasReservation = await checkReservation(_userId, widget.doctorId);
    if (!hasReservation) {
      _showAlert('Pas de réservation',
          'Vous devez avoir une réservation pour envoyer un message.');
      return;
    }

    // Vérifiez si la date de la réservation est arrivée.
    // bool reservationDateHasCome =
    //     await _checkReservationDate(_userId, widget.doctorId);
    // if (!reservationDateHasCome) {
    //   _showAlert('Trop tôt',
    //       'La date de votre réservation n\'est pas encore arrivée.');
    //   return;
    // }

    // bool isReservationTimeExceeded =
    //     await _checkReservationTimeExceeded(_userId, widget.doctorId);
    // if (isReservationTimeExceeded) {
    //   _showAlert('Trop tard',
    //       'Vous ne pouvez pas envoyer de message car l\'heure de réservation est dépassée.');
    //   return;
    // }

    // Continuez avec l'envoi du message si toutes les conditions sont remplies.
    Map<String, dynamic> messageData = {
      'senderId': _userId,
      'receiverId': widget.doctorId,
      'timestamp': Timestamp.now(),
      'conversationId': _conversationId,
      'messageText': messageText,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
    };

    try {
      await FirebaseFirestore.instance.collection('messages').add(messageData);
      _messageController.clear();
    } catch (e) {
      print("Erreur lors de l'envoi du message : $e");
    }
  }

  Future<bool> _checkReservationDate(String userId, String doctorId) async {
    // Récupérez la réservation la plus proche ou active pour vérifier la date
    QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: false)
        .limit(1)
        .get();

    if (reservationSnapshot.docs.isEmpty) {
      return false;
    }

    var data = reservationSnapshot.docs.first.data() as Map<String, dynamic>;
    DateTime reservationDate = (data['date'] as Timestamp).toDate();

    return DateTime.now().isAfter(reservationDate);
  }

  // Future<bool> _checkReservationTimeExceeded(
  //     String userId, String doctorId) async {
  //   // Récupérez la date et l'heure actuelle
  //   DateTime now = DateTime.now();

  //   // Récupérez la réservation la plus proche ou active pour vérifier l'heure
  //   QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
  //       .collection('reservations')
  //       .where('userId', isEqualTo: userId)
  //       .where('doctorId', isEqualTo: doctorId)
  //       .orderBy('date', descending: false)
  //       .limit(1)
  //       .get();

  //   if (reservationSnapshot.docs.isEmpty) {
  //     return true; // Si aucune réservation n'est trouvée, considérez que l'heure est dépassée
  //   }

  //   var data = reservationSnapshot.docs.first.data() as Map<String, dynamic>;
  //   Timestamp reservationTime = data['date'] as Timestamp;
  //   DateTime reservationEndTime =
  //       reservationTime.toDate().add(Duration(hours: 1));

  //   return now.isAfter(reservationEndTime);
  // }

  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme l'alerte
              },
            ),
          ],
        );
      },
    );
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

// Now, update your ListView.builder to use this new _buildMessageWidget function.

  @override
  Widget build(BuildContext context) {
    if (!_hasReservation) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7165D6),
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(_doctorImg),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.doctorName,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () {
              // Ici, ajoutez la fonctionnalité que vous souhaitez exécuter lorsque l'icône est tapée
              // Par exemple, naviguer vers un écran d'appel vidéo ou démarrer un appel vidéo
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
                  return Center(
                      child: Text('Erreur de chargement des messages.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Convertir les données en liste de Widgets pour l'affichage
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> message =
                        document.data()! as Map<String, dynamic>;
                    bool isMe = message['senderId'] == _userId;
                    Timestamp timestamp = message['timestamp'] as Timestamp;
                    String formattedDate =
                        DateFormat('dd MMM yyyy').format(timestamp.toDate());
                    String formattedTime =
                        DateFormat('HH:mm').format(timestamp.toDate());

                    Widget content;
                    if (message['fileUrl'] != null &&
                        message['fileUrl'].endsWith('')) {
                      // Create a widget for PDF content
                      content =
                          _buildPDFListItem(context, message['fileUrl'], isMe);
                    } else if (message['imageUrl'] != null) {
                      // Create a widget for image content
                      content = _buildImageMessage(message['imageUrl'], isMe);
                    } else {
                      // Create a widget for text content
                      content = _buildTextMessage(
                          message['messageText'] ?? 'Texte non disponible',
                          isMe);
                    }

                    return GestureDetector(
                      onLongPress: () {
                        _showDeleteDialog(document.id);
                      },
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          content,
                          Padding(
                            padding: EdgeInsets.only(
                              top: 4,
                              left: isMe ? 0 : 16,
                              right: isMe ? 16 : 0,
                            ),
                            child: Text(
                              '$formattedDate $formattedTime',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildItem(DocumentSnapshot document) {
    Map<String, dynamic> message = document.data()! as Map<String, dynamic>;
    bool isMe = message['senderId'] == _userId;

    if (message['fileUrl'] != null && message['fileUrl'].endsWith('.pdf')) {
      // Build a PDF message
      return _buildPDFListItem(context, message['fileUrl'], isMe);
    } else if (message['imageUrl'] != null) {
      // Build an image message
      return _buildImageMessage(message['imageUrl'], isMe);
    } else {
      // Build a text message
      return _buildPDFListItem(context, message['fileUrl'], isMe);
    }
  }

  Widget _buildImageMessage(String imageUrl, bool isMe) {
    // Style the image message differently based on who sent it
    var messageAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    var messageColor = isMe ? Colors.lightBlueAccent : Colors.grey[300];

    return Align(
      alignment: messageAlignment,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: messageColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.network(
          imageUrl,
          width: 150, // Or some other suitable width for image messages
          height: 100, // And height
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTextMessage(String messageText, bool isMe) {
    // Apply different styling if the message is sent by the user (_userId)
    var messageAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    var messageBgColor = isMe ? Colors.lightBlueAccent : Colors.grey[300];

    return Align(
      alignment: messageAlignment,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: messageBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          messageText,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPDFListItem(BuildContext context, String fileUrl, bool isMe) {
    // Style the PDF message differently based on who sent it
    var messageAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: messageAlignment,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.lightBlueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () => _showPdf(context, fileUrl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf,
                  color: isMe ? Colors.white : Colors.black),
              SizedBox(width: 8),
              Text(
                'PDF',
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> message, bool isMe) {
    // Formatting the timestamp
    String formattedTime = DateFormat('HH:mm:ss').format(
      (message['timestamp'] as Timestamp).toDate(),
    );

    // Message content widget (could be text, image, or PDF)
    Widget messageContent;
    if (message['imageUrl'] != null) {
      messageContent = _buildImageMessage(message['imageUrl'], isMe);
    } else if (message['fileUrl'] != null &&
        message['fileUrl'].endsWith('.pdf')) {
      messageContent = _buildPDFListItem(context, message['fileUrl'], isMe);
    } else {
      messageContent = _buildTextMessage(
          message['messageText'] ?? 'Texte non disponible', isMe);
    }

    // Return a column with message and timestamp
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        messageContent,
        Padding(
          padding: EdgeInsets.only(
            top: 4,
            right: isMe ? 8 : 0,
            left: !isMe ? 8 : 0,
          ),
          child: Text(
            formattedTime,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  Widget _buildBottomSheet() {
    return Container(
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
            onPressed: () {
              _showAttachmentOptions();
            },
            icon: Icon(Icons.add),
            iconSize: 30,
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(Icons.emoji_emotions_outlined),
          //   iconSize: 30,
          //   color: Colors.amber,
          // ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "envoiyer message ...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              String messageText = _messageController.text.trim();
              if (messageText.isNotEmpty) {
                _sendMessage(
                    messageText:
                        messageText); // Ici, spécifiez `messageText` comme un argument nommé
              }
            },
            icon: Icon(Icons.send),
            iconSize: 30,
            color: Color(0xFF7165D6),
          ),
        ],
      ),
    );
  }

  void _showPdf(BuildContext context, String pdfUrl) async {
    // Show loading indicator while downloading the PDF
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    // Download the PDF file
    var response = await http.get(Uri.parse(pdfUrl));
    var documentDirectory = await getTemporaryDirectory();
    var filePathAndName = documentDirectory.path + '/tempPdf.pdf';
    File file = File(filePathAndName);
    file.writeAsBytesSync(response.bodyBytes);

    // Close the loading indicator
    Navigator.of(context).pop();

    // Now open the PDF
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          height: 400,
          width: 300,
          child: PDFView(
            filePath: filePathAndName,
            enableSwipe: true,
            swipeHorizontal: true,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Fermer'),
            onPressed: () {
              Navigator.of(context).pop();
              // Delete the temporary file when done
              file.delete();
            },
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Envoyer une photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  }),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Envoyer un PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPDF(); // Ici, implémentez la fonction de sélection de PDF
                },
              ),
            ],
          );
        });
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      _uploadImageFile(imageFile);
      // Vous pouvez maintenant uploader le fichier vers Firebase Storage et ensuite
      // envoyer un lien vers le fichier dans un message Firestore.
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File pdfFile = File(result.files.single.path!);
      _uploadFile(pdfFile, 'application/pdf');
    }
  }

  Future<void> _uploadFile(File file, String fileType) async {
    String fileName =
        'chat_files/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);

    try {
      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();
      _sendMessage(
          fileUrl:
              downloadUrl); // Change this to your method of sending a message
    } catch (e) {
      print("Erreur lors de l'upload du fichier: $e");
    }
  }
}
