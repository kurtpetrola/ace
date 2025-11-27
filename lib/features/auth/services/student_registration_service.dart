// lib/features/auth/services/student_registration_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/models/user.dart'; // Using the updated User model (no password field)

class StudentRegistrationService {
  final DatabaseReference _dbReference =
      FirebaseDatabase.instance.ref().child("Students/");

  Future<void> register({
    required User user,
    required String password,
  }) async {
    // 1. Check if the User ID (studentId) already exists in the Realtime Database
    final dbSnapshot = await _dbReference.child(user.userId).get();
    if (dbSnapshot.exists) {
      throw Exception('Student ID already registered.');
    }

    try {
      // 2. 🛡️ Create the user SECURELY in Firebase Authentication
      // This hashes the password and saves the email for later login.
      // FIX: Removed the variable name 'userCredential' as it wasn't used.
      await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      // We can optionally use the UID from Firebase Auth as the user's identifier
      // If your 'userId' (studentId) is meant to be a custom ID (e.g., STU-001),
      // we stick to that for the RTDB key.
      final String customStudentId = user.userId;

      // 3. Save the remaining user profile data to the Realtime Database
      // The password is NOT saved to the database, only the profile details.
      await _dbReference.child(customStudentId).set(user.toJson());
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle Authentication creation errors (e.g., email already in use, weak password)
      if (e.code == 'email-already-in-use') {
        throw Exception('That email is already in use by another account.');
      }
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      }
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      // Handle database or other errors
      throw Exception('An unexpected error occurred: ${e}');
    }
  }
}
