import 'package:flutter/material.dart';
import 'package:flutter_application_1/functions/functions.dart';

Future<dynamic> dialogresev(BuildContext context) {
  return showDialog(
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
}

void modelsheet(BuildContext context, String doctorId,userId,String converId) {
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
              FunctionsSDoctor.pickImage();
            },
          ),
          ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text('Send a PDF'),
            onTap: () {
              Navigator.pop(context);
              FunctionsSDoctor.pickFile();
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Rédiger une ordonnance'),
            onTap: () {
              Navigator.pop(context);
              FunctionsSDoctor.navigateToPrescriptionPage(context, doctorId,userId,converId);
            },
          ),
        ],
      );
    },
  );
}
