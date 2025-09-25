import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellochickgu/services/user_service.dart';

class QuizService {
  QuizService._internal();
  static final QuizService instance = QuizService._internal();

  Future<void> saveQuizResult({
    required int quizNumber,
    required int correct,
    required int incorrect,
    required int pointsCollected,
    required List<dynamic> answers, // can be int? or String? per quiz
    required int timeTakenSeconds,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {
      'quiz_number': quizNumber,
      'correct': correct,
      'incorrect': incorrect,
      'points_collected': pointsCollected,
      'answers': answers,
      'time_taken_seconds': timeTakenSeconds,
      'created_at': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('quiz_results')
        .add(data);

    // Increment user's total points so homepage reflects all quiz points
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'points': FieldValue.increment(pointsCollected),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getLatestQuizResult({required int quizNumber}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('quiz_results')
        .where('quiz_number', isEqualTo: quizNumber)
        .get();

    if (snapshot.docs.isEmpty) return null;
    snapshot.docs.sort((a, b) {
      final ta = a.data()['created_at'];
      final tb = b.data()['created_at'];
      final da = (ta is Timestamp) ? ta.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      final db = (tb is Timestamp) ? tb.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });
    return snapshot.docs.first.data();
  }

  Future<void> saveLevelSummary({
    required int level,
    required int pointsCollected,
    required int timeTakenSeconds,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String username = user.email ?? user.uid;
    try {
      final doc = await UserService.instance.getCurrentUserData();
      final data = doc?.data() as Map<String, dynamic>?;
      if (data != null && data['username'] is String && (data['username'] as String).isNotEmpty) {
        username = data['username'] as String;
      }
    } catch (_) {}

    final payload = {
      'uid': user.uid,
      'username': username,
      'level': level,
      'points_collected': pointsCollected,
      'time_taken_seconds': timeTakenSeconds,
      'created_at': FieldValue.serverTimestamp(),
    };

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userRef
        .collection('level_page')
        .add(payload);

    // Also persist a quick-access highest_unlocked_level on the user doc
    try {
      final userSnap = await userRef.get();
      final currentMax = (userSnap.data()?['highest_unlocked_level'] as int?) ?? 1;
      // Unlock the NEXT level when a level is completed, capped at 11
      final int unlocked = (level >= 11) ? 11 : (level + 1);
      final newMax = unlocked > currentMax ? unlocked : currentMax;
      await userRef.set({'highest_unlocked_level': newMax}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getLevelSummary({required int level}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final qs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('level_page')
        .where('level', isEqualTo: level)
        .get();
    if (qs.docs.isEmpty) return null;
    qs.docs.sort((a, b) {
      final ta = a.data()['created_at'];
      final tb = b.data()['created_at'];
      final da = (ta is Timestamp) ? ta.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      final db = (tb is Timestamp) ? tb.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });
    return qs.docs.first.data();
  }

  Future<Map<String, dynamic>?> getLevelSummaryOrResult({required int level}) async {
    final fromSummary = await getLevelSummary(level: level);
    if (fromSummary != null) return fromSummary;

    final latest = await getLatestQuizResult(quizNumber: level);
    if (latest == null) return null;
    // Map quiz_results format to level summary shape
    return {
      'level': level,
      'points_collected': latest['points_collected'] ?? 0,
      'time_taken_seconds': latest['time_taken_seconds'] ?? 0,
      'created_at': latest['created_at'],
    };
  }

  Future<int> getHighestUnlockedLevel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 1;

    try {
      // Prefer the cached field on the user doc if present
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userSnap = await userRef.get();
      final cached = (userSnap.data()?['highest_unlocked_level'] as int?);
      if (cached != null && cached >= 1) {
        return cached.clamp(1, 11);
      }

      final qs = await userRef
          .collection('level_page')
          .get();
      int maxLevel = 0;
      for (final d in qs.docs) {
        final data = d.data();
        final lvl = (data['level'] is int)
            ? data['level'] as int
            : int.tryParse('${data['level']}') ?? 0;
        if (lvl > maxLevel) maxLevel = lvl;
      }
      return maxLevel == 0 ? 1 : (maxLevel.clamp(1, 11));
    } catch (_) {
      return 1;
    }
  }
}


