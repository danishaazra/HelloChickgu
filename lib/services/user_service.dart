import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  UserService._internal();
  static final UserService instance = UserService._internal();

  /// Get current user data from Firestore
  Future<DocumentSnapshot?> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Stream current user data from Firestore
  Stream<DocumentSnapshot?> getCurrentUserDataStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  /// Update user points
  Future<void> updatePoints(int points) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'points': points,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating points: $e');
    }
  }

  /// Update pet care stats
  Future<void> updatePetStats({
    int? hunger,
    int? cleanliness,
    int? energy,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> updates = {
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    if (hunger != null) updates['hunger'] = hunger;
    if (cleanliness != null) updates['cleanliness'] = cleanliness;
    if (energy != null) updates['energy'] = energy;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updates);
    } catch (e) {
      print('Error updating pet stats: $e');
    }
  }
}
