import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinService {
  CoinService._internal();
  static final CoinService instance = CoinService._internal();

  /// Get current user's coins
  Future<int> getCoins() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['coins'] as int?) ?? 0;
    } catch (e) {
      print('Error fetching coins: $e');
      return 0;
    }
  }

  /// Add coins to user's account
  Future<void> addCoins(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'coins': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding coins: $e');
    }
  }

  /// Spend coins (returns true if successful, false if insufficient coins)
  Future<bool> spendCoins(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final currentCoins = await getCoins();
      if (currentCoins < amount) return false;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'coins': FieldValue.increment(-amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error spending coins: $e');
      return false;
    }
  }

  /// Stream of user's coins for real-time updates
  Stream<int> getCoinsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return (data?['coins'] as int?) ?? 0;
    });
  }
}
