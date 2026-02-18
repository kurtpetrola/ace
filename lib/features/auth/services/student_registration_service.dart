// lib/features/auth/services/student_registration_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/models/user.dart';

class StudentRegistrationService {
  final DatabaseReference _dbReference = FirebaseDatabase.instance
      .ref()
      .child('Students'); // Removed trailing slash

  /// Registers a new student using Firebase Auth and saves their profile data.
  ///
  /// Best Practice: We use the secure Firebase Auth UID as the Realtime Database key
  /// to ensure the profile is perfectly linked to the Auth record.
  ///
  /// @param user The complete User profile model (which contains the custom Student ID).
  /// @param password The raw password for Firebase Auth registration.
  Future<void> register({
    required User user,
    required String password,
  }) async {
    fb_auth.UserCredential userCredential;

    try {
      // 1. Create the user SECURELY in Firebase Authentication
      // This hashes the password and saves the email for later login.
      userCredential =
          await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      // 2. Database Check (Must be done AFTER auth to satisfy Security Rules)
      // Check if the custom Student ID (e.g., STU-001) is already in use
      final dbSnapshot = await _dbReference.child(user.userId).get();
      if (dbSnapshot.exists) {
        await userCredential.user?.delete();
        throw Exception('Student ID (${user.userId}) already registered.');
      }

      final authUid = userCredential.user?.uid;

      // Sanity check: Ensure the created user has a UID
      if (authUid == null) {
        throw Exception('Firebase Auth failed to generate a secure UID.');
      }

      // 3. Save the remaining user profile data to the Realtime Database
      // We use the Firebase Auth UID (authUid) as the database key.
      // The user's custom studentId (user.uid) is preserved inside the document.
      final Map<String, dynamic> userData = user.toJson();
      // SECURITY: Save the Auth UID so we can link this record to the logged-in user in Security Rules
      userData['uid'] = authUid;

      await _dbReference.child(user.userId).set(userData);

      // 4. Optional: Sign out the user immediately after registration
      // This ensures the user is directed to the login screen next.
      await fb_auth.FirebaseAuth.instance.signOut();
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle Authentication creation errors
      String errorMsg;
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = 'That email is already in use by another account.';
          break;
        case 'weak-password':
          errorMsg = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          errorMsg = 'The email address is not valid.';
          break;
        default:
          errorMsg = 'Registration failed: ${e.message}';
          break;
      }
      throw Exception(errorMsg);
    } catch (e) {
      // If the error message is already formatted by us (Exception: ...), rethrow it
      if (e.toString().contains('already registered')) {
        rethrow;
      }
      // Handle database or other errors
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
