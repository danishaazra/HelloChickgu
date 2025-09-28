import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Course {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String visibility;
  final int moduleCount;
  final String estimatedDuration;

  const Course({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.visibility,
    this.moduleCount = 0,
    this.estimatedDuration = '0h 0m',
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      title: data['title'] ?? 'Untitled Course',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      visibility: data['visibility'] ?? 'public',
      moduleCount: data['moduleCount'] ?? 0,
      estimatedDuration: data['estimatedDuration'] ?? '0h 0m',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'visibility': visibility,
      'moduleCount': moduleCount,
      'estimatedDuration': estimatedDuration,
    };
  }
}

class LibraryService {
  static final LibraryService _instance = LibraryService._internal();
  factory LibraryService() => _instance;
  LibraryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all public courses
  Stream<List<Course>> getCoursesStream() {
    return _firestore
        .collection('courses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Course.fromFirestore(doc))
          .where((course) => course.visibility == 'public')
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by creation date, newest first
    });
  }

  /// Get courses once (for non-streaming usage)
  Future<List<Course>> getCourses() async {
    final snapshot = await _firestore
        .collection('courses')
        .get();
    
    return snapshot.docs
        .map((doc) => Course.fromFirestore(doc))
        .where((course) => course.visibility == 'public')
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by creation date, newest first
  }

  /// Get a specific course by ID
  Future<Course?> getCourse(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();
      if (doc.exists) {
        return Course.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching course: $e');
      return null;
    }
  }

  /// Get modules for a specific course
  Future<List<Map<String, dynamic>>> getCourseModules(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .orderBy('index')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Untitled Module',
          'content': data['content'] ?? '',
          'index': data['index'] ?? 0,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching modules: $e');
      return [];
    }
  }

  /// Get user's progress for a course
  Future<Map<String, dynamic>?> getUserProgress(String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courseProgress')
          .doc(courseId)
          .get();
      
      return doc.data();
    } catch (e) {
      print('Error fetching user progress: $e');
      return null;
    }
  }

  /// Update user's progress for a course
  Future<void> updateUserProgress(String courseId, Map<String, dynamic> progress) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courseProgress')
          .doc(courseId)
          .set(progress, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }

  /// Check if user has bookmarked a course
  Future<bool> isCourseBookmarked(String courseTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final bookmarks = (data?['bookmarked_courses'] as List?)?.cast<String>() ?? [];
      return bookmarks.contains(courseTitle);
    } catch (e) {
      print('Error checking bookmark: $e');
      return false;
    }
  }

  /// Toggle course bookmark
  Future<void> toggleCourseBookmark(String courseTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data() ?? {};
        final current = (data['bookmarked_courses'] as List?)?.cast<String>() ?? [];
        
        if (current.contains(courseTitle)) {
          current.remove(courseTitle);
        } else {
          current.add(courseTitle);
        }
        
        transaction.set(docRef, {'bookmarked_courses': current}, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  /// Get user's most recent course and progress
  Future<Map<String, dynamic>?> getRecentCourseProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      
      if (data == null) return null;
      
      final recentCourseId = data['recent_course_id'] as String?;
      final recentCourseTitle = data['recent_course_title'] as String?;
      final lastAccessed = (data['last_accessed'] as Timestamp?)?.toDate();
      
      if (recentCourseId == null || recentCourseTitle == null) return null;
      
      // Get progress for the recent course
      final progress = await getUserProgress(recentCourseId);
      final modules = await getCourseModules(recentCourseId);
      
      return {
        'courseId': recentCourseId,
        'courseTitle': recentCourseTitle,
        'lastAccessed': lastAccessed,
        'completedModules': progress?['completed_modules'] ?? [],
        'totalModules': modules.length,
        'progressPercentage': modules.isNotEmpty 
            ? ((progress?['completed_modules'] as List?)?.length ?? 0) / modules.length
            : 0.0,
      };
    } catch (e) {
      print('Error fetching recent course progress: $e');
      return null;
    }
  }

  /// Update user's recent course when they access it
  Future<void> updateRecentCourse(String courseId, String courseTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'recent_course_id': courseId,
        'recent_course_title': courseTitle,
        'last_accessed': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating recent course: $e');
    }
  }

  /// Mark a module as completed
  Future<void> markModuleCompleted(String courseId, String moduleId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courseProgress')
          .doc(courseId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data() ?? {};
        final completedModules = (data['completed_modules'] as List?)?.cast<String>() ?? [];
        
        if (!completedModules.contains(moduleId)) {
          completedModules.add(moduleId);
        }
        
        transaction.set(docRef, {
          'completed_modules': completedModules,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error marking module completed: $e');
    }
  }
}
