// lib/features/auth/services/student_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/models/user.dart';
import 'dart:convert';

import 'package:ace/features/auth/services/auth_service_interface.dart';

class StudentAuthService implements AuthServiceInterface {
  final Box _loginbox = Hive.box("_loginbox");
  static const String wrongCredentialsError = 'Wrong username or password';

  @override
  Future<void> login({
    required String email, // Changed from id to email
    required String password,
  }) async {
    final String studentEmail = email.trim();

    try {
      // 1. Validate password SECURELY using Firebase Authentication
      // This now happens FIRST, avoiding unauthenticated database reads.
      final userCredential =
          await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: studentEmail,
        password: password,
      );

      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw Exception("Authentication successful but user is null.");
      }

      // 2. Fetch student data to get the ID and Name for the session
      // We query by email since we no longer have the ID upfront.
      // Rules allow this read because auth != null now.
      DatabaseReference dbReference =
          FirebaseDatabase.instance.ref().child("Students");

      final snapshot =
          await dbReference.orderByChild("email").equalTo(studentEmail).get();

      if (!snapshot.exists || snapshot.value == null) {
        // This is a critical edge case: Auth works, but no profile exists in DB.
        // Should probably logout to prevent ghost sessions.
        await fb_auth.FirebaseAuth.instance.signOut();
        throw Exception("User profile not found in database.");
      }

      // 3. Extract Profile Data
      // The result is a Map where keys are IDs (e.g. STU-001)
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      // We expect only one match since emails should be unique
      var entry = values.entries.first;
      String studentId = entry.key;
      Map<String, dynamic> userDataMap =
          jsonDecode(jsonEncode(entry.value)); // Ensure strictly string keys

      User user = User.fromJson(userDataMap);
      final String studentName = user.fullname;

      // 4. Successful login: Save state to Hive
      await _loginbox.put("isLoggedIn", true);
      await _loginbox.put(
          "UserType", "Student"); // <-- Ensures WrapperScreen works
      await _loginbox.put("User", studentId);
      await _loginbox.put("UserName", studentName);
      return;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle Auth errors
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Exception(wrongCredentialsError);
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      // Handle other errors (e.g. database failures)
      throw Exception('An error occurred: $e');
    }
  }
}
