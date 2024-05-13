import 'package:flutter/material.dart';

class PrescriptionPage extends StatefulWidget {
  final String doctorId;

  PrescriptionPage({required this.doctorId});

  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  final TextEditingController _prescriptionController = TextEditingController();
  final String _doctorName = "Docteur Martin";
  final String _specialty = "Médecine Générale";
  final String _degree = "Diplômé de la Faculté de Marseille";
  final String _address = "16 rue de la Paix\n13000 Marseille";
  final String _phone = "Tél. cabinet: 04 00 00 00 00";
  final String _patientName = "Madame Dupont Germaine";
  final String _patientDetails = "59 ans, 64 kg";
  final String _date = "Le 4 février 2020";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordonnance Médicale'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth < 400 ? 14 : 16;
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
                        child: Text('$_doctorName\n$_specialty\n$_degree',
                            style: TextStyle(fontSize: fontSize)),
                        flex: 2,
                      ),
                      Flexible(
                        child: Text(_address,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: fontSize)),
                        flex: 2,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(_phone,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: fontSize)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_date, style: TextStyle(fontSize: fontSize)),
                      Text('$_patientName\n$_patientDetails',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: fontSize)),
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
                    maxLines: 5,
                    style: TextStyle(fontSize: fontSize),
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

  void _sendPrescription() {
    if (_prescriptionController.text.isNotEmpty) {
      // Code pour envoyer l'ordonnance au patient
      print('Ordonnance envoyée : ${_prescriptionController.text}');
      Navigator.pop(context);
    }
  }
}
