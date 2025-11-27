// lib/features/auth/services/student_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/models/user.dart';
import 'dart:convert';

class StudentAuthService {
  final Box _loginbox = Hive.box("_loginbox");
  static const String wrongCredentialsError = 'Wrong username or password';

  Future<void> login({
    required String studentId,
    required String password,
  }) async {
    // 1. Efficiently fetch student data to get the required email
    DatabaseReference dbReference = FirebaseDatabase.instance
        .ref()
        .child("Students/$studentId"); // Targeted fetch
    final snapshot = await dbReference.get();

    if (!snapshot.exists || snapshot.value == null) {
      throw Exception(wrongCredentialsError);
    }

    // Decode and map the data
    Map<String, dynamic> userDataMap = jsonDecode(jsonEncode(snapshot.value));

    // ⚠️ Crucial Debugging Point: This line will fail if 'email' is missing in the database node!
    User user = User.fromJson(userDataMap);
    final String studentEmail =
        user.email; // We need the email for Firebase Auth

    // --- CRITICAL CHECK ADDED HERE ---
    if (studentEmail.isEmpty) {
      print(
          'ERROR: User profile found, but email field is empty for $studentId.');
      throw Exception(wrongCredentialsError);
    }
    // ---------------------------------

    print('DEBUG: Attempting login for email: $studentEmail');

    try {
      // 2. 🛡️ Validate password SECURELY using Firebase Authentication
      await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: studentEmail,
        password: password,
      );

      // 3. Successful login: Save state to Hive
      await _loginbox.put("isLoggedIn", true);
      await _loginbox.put(
          "UserType", "Student"); // <-- Ensures WrapperScreen works
      await _loginbox.put("User", studentId);
      return;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle Auth errors
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Exception(wrongCredentialsError);
      }
      throw Exception('Login failed: ${e.message}');
    }
  }
}
