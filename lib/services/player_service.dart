import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerService {
  PlayerService._internal();
  static final PlayerService instance = PlayerService._internal();

  /// Register a new player in the Players collection
  Future<void> registerPlayer(String userId, String username) async {
    final docRef = FirebaseFirestore.instance.collection('Players').doc(userId);

    await docRef.set({
      'username': username,
      'points': 0,
      'level': 1,
      'currentRoom': 'Living Room',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Get player data by userId
  Future<DocumentSnapshot> getPlayer(String userId) async {
    return await FirebaseFirestore.instance
        .collection('Players')
        .doc(userId)
        .get();
  }

  /// Update player points
  Future<void> updatePlayerPoints(String userId, int points) async {
    await FirebaseFirestore.instance
        .collection('Players')
        .doc(userId)
        .update({
      'points': points,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Update player level
  Future<void> updatePlayerLevel(String userId, int level) async {
    await FirebaseFirestore.instance
        .collection('Players')
        .doc(userId)
        .update({
      'level': level,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Update player current room
  Future<void> updatePlayerRoom(String userId, String room) async {
    await FirebaseFirestore.instance
        .collection('Players')
        .doc(userId)
        .update({
      'currentRoom': room,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Get all players (for leaderboard)
  Future<QuerySnapshot> getAllPlayers() async {
    return await FirebaseFirestore.instance
        .collection('Players')
        .orderBy('points', descending: true)
        .get();
  }
}
