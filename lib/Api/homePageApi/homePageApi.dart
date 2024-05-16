import 'package:cloud_firestore/cloud_firestore.dart';

class HomePageApi {
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAlldoctors(
      String searchQuery) {
    return (searchQuery.isEmpty)
        ? FirebaseFirestore.instance.collection('doctors').snapshots()
        : FirebaseFirestore.instance
            .collection('doctors')
            .where('Nom', isGreaterThanOrEqualTo: searchQuery)
            .where('Nom', isLessThanOrEqualTo: searchQuery + '\uf8ff')
            .snapshots();
  }

  static Future<String?> getDoctorIdForUser(String userId) async {
    QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('id_utilisateur', isEqualTo: userId)
        .get();

    if (reservationSnapshot.docs.isNotEmpty) {
      // Récupérez l'identifiant du premier médecin avec lequel l'utilisateur a réservé
      return reservationSnapshot.docs.first.get('id_doctor');
    } else {
      // Aucune réservation trouvée pour cet utilisateur
      return null;
    }
  }

  static Stream<QuerySnapshot> chatStream(String _conversationId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('conversationId', isEqualTo: _conversationId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<bool> checkReservation(String userId, String doctorId) async {
    QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .where('doctorId', isEqualTo: doctorId)
        .get();

    return reservationSnapshot.docs.isNotEmpty;
  }
}
