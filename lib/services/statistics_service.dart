import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsService {
  StatisticsService._internal();
  static final StatisticsService instance = StatisticsService._internal();

  /// Get user statistics for spider web chart
  /// Returns a map with normalized values (0.0 to 1.0) for each category
  Future<Map<String, double>> getUserStatistics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _getDefaultStatistics();

    try {
      // Fetch user data
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDoc.exists) return _getDefaultStatistics();

      final userData = userDoc.data() as Map<String, dynamic>;

      // Fetch quiz results for level analysis
      final quizResults =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('quiz_results')
              .get();

      // Fetch level page results for training analysis
      final levelResults =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('level_page')
              .get();

      return _calculateStatistics(
        userData,
        quizResults.docs,
        levelResults.docs,
      );
    } catch (e) {
      print('Error fetching user statistics: $e');
      return _getDefaultStatistics();
    }
  }

  /// Calculate statistics based on user data and quiz/level results
  Map<String, double> _calculateStatistics(
    Map<String, dynamic> userData,
    List<QueryDocumentSnapshot> quizResults,
    List<QueryDocumentSnapshot> levelResults,
  ) {
    // Initialize categories
    double understanding = 0.0; // Level 1
    double solving = 0.0; // Level 2
    double patterns = 0.0; // Level 3
    double memory = 0.0; // Level 4
    double logic = 0.0; // Training

    // Calculate Understanding (Level 1)
    final level1Results =
        quizResults.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['quiz_number'] == 1;
        }).toList();

    if (level1Results.isNotEmpty) {
      understanding = _calculateLevelScore(level1Results);
    }

    // Calculate Solving (Level 2)
    final level2Results =
        quizResults.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['quiz_number'] == 2;
        }).toList();

    if (level2Results.isNotEmpty) {
      solving = _calculateLevelScore(level2Results);
    }

    // Calculate Patterns (Level 3)
    final level3Results =
        quizResults.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['quiz_number'] == 3;
        }).toList();

    if (level3Results.isNotEmpty) {
      patterns = _calculateLevelScore(level3Results);
    }

    // Calculate Memory (Level 4)
    final level4Results =
        quizResults.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['quiz_number'] == 4;
        }).toList();

    if (level4Results.isNotEmpty) {
      memory = _calculateLevelScore(level4Results);
    }

    // Calculate Logic (Training) - based on level_page results
    if (levelResults.isNotEmpty) {
      logic = _calculateTrainingScore(levelResults);
    }

    return {
      'understanding': understanding,
      'solving': solving,
      'patterns': patterns,
      'memory': memory,
      'logic': logic,
    };
  }

  /// Calculate score for a specific level based on quiz results
  double _calculateLevelScore(List<QueryDocumentSnapshot> results) {
    if (results.isEmpty) return 0.0;

    double totalScore = 0.0;
    int attempts = results.length;

    for (final doc in results) {
      final data = doc.data() as Map<String, dynamic>;
      final correct = data['correct'] as int? ?? 0;
      final incorrect = data['incorrect'] as int? ?? 0;
      final totalQuestions = correct + incorrect;

      if (totalQuestions > 0) {
        final accuracy = correct / totalQuestions;
        totalScore += accuracy;
      }
    }

    // Return average accuracy normalized to 0-1 range
    return (totalScore / attempts).clamp(0.0, 1.0);
  }

  /// Calculate training score based on level page results
  double _calculateTrainingScore(List<QueryDocumentSnapshot> results) {
    if (results.isEmpty) return 0.0;

    double totalScore = 0.0;
    int attempts = results.length;

    for (final doc in results) {
      final data = doc.data() as Map<String, dynamic>;
      final pointsCollected = data['points_collected'] as int? ?? 0;
      final timeTaken = data['time_taken_seconds'] as int? ?? 1;

      // Calculate score based on points per second (efficiency)
      // Normalize to 0-1 range (assuming max 100 points in 60 seconds = 1.67 points/sec)
      final efficiency = pointsCollected / timeTaken;
      final normalizedEfficiency = (efficiency / 1.67).clamp(0.0, 1.0);
      totalScore += normalizedEfficiency;
    }

    return (totalScore / attempts).clamp(0.0, 1.0);
  }

  /// Get default statistics when no data is available
  Map<String, double> _getDefaultStatistics() {
    return {
      'understanding': 0.0,
      'solving': 0.0,
      'patterns': 0.0,
      'memory': 0.0,
      'logic': 0.0,
    };
  }

  /// Stream user statistics for real-time updates
  Stream<Map<String, double>> getUserStatisticsStream() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield _getDefaultStatistics();
      return;
    }

    // Stream user document changes
    await for (final userDoc
        in FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()) {
      if (!userDoc.exists) {
        yield _getDefaultStatistics();
        continue;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Fetch latest quiz results
      final quizResults =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('quiz_results')
              .get();

      // Fetch latest level results
      final levelResults =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('level_page')
              .get();

      yield _calculateStatistics(userData, quizResults.docs, levelResults.docs);
    }
  }
}
