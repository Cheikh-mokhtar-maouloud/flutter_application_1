import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import '../functions/functions.dart';

class PrescriptionPage extends StatefulWidget {
  final String doctorId;
  final String userId;
  final String conversationId;

  PrescriptionPage({
    required this.doctorId,
    required this.userId,
    required this.conversationId,
  });

  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  final TextEditingController _prescriptionController = TextEditingController();

  final String _doctorName = "Docteur Martin";
  final String _specialty = "Médecine Générale";
  final String _phone = "Tél. cabinet: 04 00 00 00 00";
  final String _patientName = "Madame Dupont Germaine";
  final String _date = "Le 4 février 2020";
  final TextEditingController salem = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordonnance Médicale'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth < 600 ? 10 : 16;
          double padding = constraints.maxWidth * 0.05;
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text('$_doctorName\n$_specialty\n',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        flex: 2,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(_phone,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Center(
                    child: Text('$_patientName\n',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_date,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(thickness: 1),
                  TextField(
                    controller: _prescriptionController,
                    decoration: InputDecoration(
                      hintText:
                          'Entrez le médicament et les instructions ici...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(8),
                    ),
                    maxLines: 10,
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      child: Text('Envoyer'),
                      onPressed: () => _sendPrescription(),
                      style: ElevatedButton.styleFrom(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendPrescription() async {
    if (_prescriptionController.text.isNotEmpty) {
      // Convert the prescription to a PDF file

      try {
        // Convert the prescription to a PDF file
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('$_doctorName\n$_specialty\n'),
                pw.SizedBox(height: 8),
                pw.Text(_phone, textAlign: pw.TextAlign.right),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(_date),
                    pw.Text('$_patientName\n', textAlign: pw.TextAlign.right),
                  ],
                ),
                pw.Divider(thickness: 1),
                pw.Text(_prescriptionController.text),
              ],
            ),
          ),
        );

        // Save the PDF to a file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/prescription.pdf');
        await file.writeAsBytes(await pdf.save());

        // Upload the file to Firebase Storage
        String fileName =
            'prescriptions/${DateTime.now().millisecondsSinceEpoch}.pdf';
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(file);

        // Get the download URL
        String downloadURL = await ref.getDownloadURL();

        // Send the download URL as a message in the chat
        FunctionsSDoctor.sendMessage(
          'Prescription',
          null,
          downloadURL,
          widget.doctorId,
          widget.userId,
          widget.conversationId,
          null,
          true,
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de l\'envoi de l\'ordonnance.'),
        ));
      }
    }
  }
}
