// lib/features/auth/services/admin_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/models/user.dart';
import 'dart:convert';

import 'package:ace/features/auth/services/auth_service_interface.dart';

class AdminAuthService implements AuthServiceInterface {
  final Box _loginbox = Hive.box("_loginbox");
  static const String wrongCredentialsError = 'Wrong username or password';

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final String adminEmail = email.trim();

    try {
      // 1. Validate password SECURELY using Firebase Authentication
      final userCredential =
          await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: password,
      );

      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw Exception("Authentication successful but user is null.");
      }

      // 2. Fetch admin data
      // Query by email.
      DatabaseReference dbReference =
          FirebaseDatabase.instance.ref().child("Admins");

      final snapshot =
          await dbReference.orderByChild("email").equalTo(adminEmail).get();

      if (!snapshot.exists || snapshot.value == null) {
        await fb_auth.FirebaseAuth.instance.signOut();
        throw Exception(wrongCredentialsError);
      }

      // 3. Extract Profile Data
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      var entry = values.entries.first;
      String adminId = entry.key;
      Map<String, dynamic> userDataMap = jsonDecode(jsonEncode(entry.value));

      User user = User.fromJson(userDataMap);
      final String adminName = user.fullname;

      // 4. Successful login: Save state to Hive
      await _loginbox.put("isLoggedIn", true);
      await _loginbox.put("UserType", "Admin");
      await _loginbox.put("User", adminId);
      await _loginbox.put("UserName", adminName);
      return;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Exception(wrongCredentialsError);
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
