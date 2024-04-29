import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddAvailabilityPage extends StatefulWidget {
  final String doctorId;

  AddAvailabilityPage({required this.doctorId});

  @override
  _AddAvailabilityPageState createState() => _AddAvailabilityPageState();
}

class _AddAvailabilityPageState extends State<AddAvailabilityPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String _selectedType = 'en_ligne'; // La valeur par défaut est 'en_ligne'

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<bool> _isTimeSlotAvailable(DateTime selectedDateTime) async {
    final int minutesInterval = 30;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('availabilities')
        .where('doctorId', isEqualTo: widget.doctorId)
        .get();

    for (var doc in snapshot.docs) {
      final existingDateTime = (doc['date'] as Timestamp).toDate();
      // Vérifier si le créneau est trop proche d'un créneau existant (avant ou après)
      if (existingDateTime
              .subtract(Duration(minutes: minutesInterval))
              .isBefore(selectedDateTime) &&
          existingDateTime
              .add(Duration(minutes: minutesInterval))
              .isAfter(selectedDateTime)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _addOrUpdateAvailability({String? docId}) async {
    if (_formKey.currentState!.validate()) {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateFormat timeFormat = DateFormat('HH:mm');
      DateTime now = DateTime.now();

      DateTime selectedDate = dateFormat.parseStrict(_dateController.text);
      DateTime selectedTime = timeFormat.parseStrict(_timeController.text);

      // Combinez la date et l'heure pour obtenir un objet DateTime complet
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Vérifiez si la date et l'heure combinées sont dans le futur
      if (selectedDateTime.isBefore(now)) {
        // Afficher un message d'erreur si la date et l'heure sont passées
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Impossible d\'ajouter une disponibilité dans le passé.')),
        );
        return;
      }

      // Vérifier si le créneau horaire est disponible
      if (!await _isTimeSlotAvailable(selectedDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Il doit y avoir au moins 30 minutes entre chaque rendez-vous.')),
        );
        return;
      }

      // Préparez les données à envoyer à Firestore
      Timestamp dateTimestamp = Timestamp.fromDate(selectedDateTime);
      Map<String, dynamic> data = {
        'doctorId': widget.doctorId,
        'date': dateTimestamp,
        'time': timeFormat.format(selectedDateTime),
        'type': _selectedType,
        'reserved': false,
      };

      if (docId == null) {
        // Ajoutez une nouvelle disponibilité
        await FirebaseFirestore.instance.collection('availabilities').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disponibilité ajoutée avec succès.')),
        );
      } else {
        // Mettre à jour une disponibilité existante
        await FirebaseFirestore.instance
            .collection('availabilities')
            .doc(docId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disponibilité mise à jour avec succès.')),
        );
      }

      // Réinitialisez les champs de formulaire
      _dateController.clear();
      _timeController.clear();
      setState(() {
        _selectedType = 'en_ligne';
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(2101),
    );
    if (picked != null &&
        picked.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay now = TimeOfDay.now();
    final DateTime today = DateTime.now();
    final DateTime selectedDate =
        DateFormat('dd/MM/yyyy').parseStrict(_dateController.text);
    final DateTime todayWithSelectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: today.isAtSameMomentAs(todayWithSelectedDate)
          ? now
          : TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      final DateTime combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      if (combinedDateTime.isAfter(DateTime.now())) {
        setState(() {
          _timeController.text = picked.format(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Vous ne pouvez pas sélectionner une heure dans le passé."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer les disponibilités'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAvailabilityList(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: [
                        DropdownMenuItem(
                            value: 'en_ligne', child: Text('En ligne')),
                        DropdownMenuItem(
                            value: 'presentiel', child: Text('Présentiel')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value ?? 'en_ligne';
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Type de consultation',
                        icon: Icon(Icons.type_specimen),
                      ),
                    ),
                    InkWell(
                      onTap: _selectDate,
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: 'Date (dd/MM/yyyy)',
                            icon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            // La validation reste inchangée
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _selectTime,
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _timeController,
                          decoration: InputDecoration(
                            labelText: 'Heure (HH:mm)',
                            icon: Icon(Icons.access_time),
                          ),
                          validator: (value) {
                            // La validation reste inchangée
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _addOrUpdateAvailability(docId: null),
                      child: Text('Ajouter Disponibilité'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('availabilities')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('reserved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Erreur: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("Aucune disponibilité à afficher.");
        }
        return ListView(
          shrinkWrap: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            // Assurez-vous que la date est un Timestamp avant de tenter de le convertir.
            DateTime dateTime;
            if (data['date'] is Timestamp) {
              dateTime = (data['date'] as Timestamp).toDate();
            } else {
              // Afficher une erreur ou attribuer une date par défaut si nécessaire
              // Ici, nous retournons un widget vide et logguons une erreur
              print('La date n\'est pas un Timestamp.');
              return SizedBox.shrink();
            }

            String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

            return ListTile(
              title: Text('$formattedDate - ${data['time']}'),
              subtitle: Text('Type: ${data['type']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize
                    .min, // Ajouté pour maintenir les boutons sur une seule ligne
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editAvailability(document.id, data),
                  ),
                  // Ajouté un IconButton pour la suppression
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteAvailability(document.id),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _deleteAvailability(String docId) {
    // Affichez un AlertDialog pour confirmer la suppression
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content:
              Text('Êtes-vous sûr de vouloir supprimer cette disponibilité ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('availabilities')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop(); // Fermez la boîte de dialogue
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Disponibilité supprimée avec succès.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _editAvailability(String docId, Map<String, dynamic> data) {
    // Fill the controllers with the existing data to edit
    _dateController.text =
        DateFormat('dd/MM/yyyy').format((data['date'] as Timestamp).toDate());
    _timeController.text = data['time'];
    _selectedType = data['type'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier la disponibilité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date (dd/MM/yyyy)',
                  icon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une date';
                  }
                  try {
                    DateFormat('dd/MM/yyyy').parseStrict(value);
                  } catch (e) {
                    return 'Format de date invalide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Heure (HH:mm)',
                  icon: Icon(Icons.access_time),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une heure';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: [
                  DropdownMenuItem(value: 'en_ligne', child: Text('En ligne')),
                  DropdownMenuItem(
                      value: 'presentiel', child: Text('Présentiel')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Type de consultation',
                  icon: Icon(Icons.type_specimen),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Sauvegarder'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addOrUpdateAvailability(docId: docId);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }
}
