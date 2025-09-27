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
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      // Apply offline decay based on time since lastUpdated
      await _applyDecayIfNeeded(user.uid, snap);
      return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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
    double? hunger,
    double? cleanliness,
    double? energy,
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

  /// Apply time-based decay of 0.1 points per minute since lastUpdated
  Future<void> _applyDecayIfNeeded(String uid, DocumentSnapshot snap) async {
    try {
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) return;
      final Timestamp? ts = data['lastUpdated'] as Timestamp?;
      final double hunger = (data['hunger'] as num?)?.toDouble() ?? 100.0;
      final double energy = (data['energy'] as num?)?.toDouble() ?? 100.0;
      final double cleanliness = (data['cleanliness'] as num?)?.toDouble() ?? 100.0;

      DateTime last = ts?.toDate() ?? DateTime.now();
      final int minutes = DateTime.now().difference(last).inMinutes;
      if (minutes <= 0) return;

      double delta = (minutes * 0.1);
      final double newHunger = (hunger - delta).clamp(0.0, 100.0);
      final double newEnergy = (energy - delta).clamp(0.0, 100.0);
      final double newClean = (cleanliness - delta).clamp(0.0, 100.0);

      if (newHunger != hunger || newEnergy != energy || newClean != cleanliness) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'hunger': newHunger,
          'energy': newEnergy,
          'cleanliness': newClean,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error applying decay: $e');
    }
  }

  /// Public helper to apply decay immediately based on current stored timestamp
  Future<void> applyDecayNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      await _applyDecayIfNeeded(user.uid, snap);
    } catch (e) {
      print('Error applying decay now: $e');
    }
  }
}
