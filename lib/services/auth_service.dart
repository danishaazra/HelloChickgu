import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player_service.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    } catch (_) {
      throw const AuthException('Sign in failed. Please try again.');
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Update display name in Firebase Auth
        await user.updateDisplayName(name);

        // Try to save user profile in Firestore, but do not fail signup if this part fails
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'email': email.trim(),
            'uid': user.uid,
            'username': name.trim(),
            'points': 100,
            'level': 1,
            'currentRoom': 'PetHomePage',
            'lastUpdated': FieldValue.serverTimestamp(),
            
            // Pet care system - all start at 100 for new users
            'hunger': 100,          // 0 = starving, 100 = full
            'cleanliness': 100,     // 0 = dirty, 100 = clean
            'energy': 100,          // 0 = tired, 100 = well-rested
            
            // Outfit system - empty for new users
            'currentOutfit': {
              'hat': null,
              'glasses': null
            },
            
            // Inventory system - empty for new users
            'ownedItems': {
              'hat': [],
              'glasses': [],
              'consumables': {
                'soap': 0,
                'food': 0
              }
            }
          });

          // Also register the player in the Players collection
          await PlayerService.instance.registerPlayer(user.uid, name.trim());
        } on FirebaseException catch (e) {
          // Surface a diagnostic message but proceed
          // ignore: avoid_print
          print('Firestore profile write failed: ${e.code} - ${e.message}');
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromCode(e.code));
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _messageFromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
