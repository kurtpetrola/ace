// lib/features/auth/services/admin_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:convert';
import 'package:ace/models/user.dart';

class AdminAuthService {
  final Box _loginbox = Hive.box("_loginbox");

  static const String wrongCredentialsError = 'Wrong username or password';

  Future<void> login({
    required String adminId, // The ID entered by the admin (e.g., ADM-001)
    required String password,
  }) async {
    // 1. Fetch data for the specific adminId from the Realtime Database
    DatabaseReference dbReference =
        FirebaseDatabase.instance.ref().child("Admins/$adminId");
    final snapshot = await dbReference.get();

    if (!snapshot.exists || snapshot.value == null) {
      throw Exception(wrongCredentialsError);
    }

    // Decode and map the data to get the required email
    Map<String, dynamic> userDataMap = jsonDecode(jsonEncode(snapshot.value));
    // Ensure your User model has the 'email' field and it's correctly mapped
    User user = User.fromJson(userDataMap);

    final String adminEmail = user.email;

    try {
      // 2. 🛡️ Validate password SECURELY using Firebase Authentication (Auth uses Email)
      await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: password,
      );

      // 3. Successful login: Save state to Hive
      await _loginbox.put("isLoggedIn", true);
      await _loginbox.put("UserType", "Admin");
      await _loginbox.put(
          "User", adminId); // Save the ADM-001 ID for the WrapperScreen
      return; // Success
    } on fb_auth.FirebaseAuthException catch (e) {
      // Catch specific Auth errors and throw the generic message for the Notifier
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Exception(wrongCredentialsError);
      }
      throw Exception('Login failed: ${e.message}');
    }
  }
}
