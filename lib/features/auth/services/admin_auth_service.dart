// lib/features/auth/services/admin_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/models/user.dart';
import 'dart:convert';

class AdminAuthService {
  final Box _loginbox = Hive.box("_loginbox");
  static const String wrongCredentialsError = 'Wrong username or password';

  Future<void> login({
    required String adminId, // The ID entered by the admin (e.g., ADM-001)
    required String password,
  }) async {
    // 1. Fetch data directly using the custom adminId as the database KEY.
    // This is the correct approach given your database structure (e.g., /Admins/ADM-001).
    DatabaseReference dbReference =
        FirebaseDatabase.instance.ref().child("Admins/$adminId");

    final snapshot = await dbReference.get();

    if (!snapshot.exists || snapshot.value == null) {
      // If the direct fetch fails, the admin ID doesn't exist.
      throw Exception(wrongCredentialsError);
    }

    // Decode and map the data to get the required email and name
    Map<String, dynamic> userDataMap = jsonDecode(jsonEncode(snapshot.value));
    User user = User.fromJson(userDataMap);

    final String adminEmail = user.email;
    final String adminName = user.fullname;

    // Check if email is valid for Auth
    if (adminEmail.isEmpty) {
      print(
          'ERROR: Admin profile found, but email field is empty for $adminId.');
      throw Exception(wrongCredentialsError);
    }

    try {
      // 2. Validate password SECURELY using Firebase Authentication (Auth uses Email)
      await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: password,
      );

      // 3. Successful login: Save state to Hive
      await _loginbox.put("isLoggedIn", true);
      // CRITICAL: Ensure this is set correctly for WrapperScreen routing
      await _loginbox.put("UserType", "Admin");
      await _loginbox.put("User", adminId);
      await _loginbox.put("UserName", adminName);

      return; // Success
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle Authentication errors (user not found, wrong password, etc.)
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Exception(wrongCredentialsError);
      }
      throw Exception('Login failed: ${e.message}');
    }
  }
}
