// lib/features/auth/services/teacher_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/models/user.dart';
import 'dart:convert';

import 'package:ace/features/auth/services/auth_service_interface.dart';

class TeacherAuthService implements AuthServiceInterface {
  final Box _loginbox = Hive.box("_loginbox");
  static const String wrongCredentialsError = 'Wrong username or password';

  @override
  Future<void> login({
    required String id,
    required String password,
  }) async {
    final String teacherId = id;
    // 1. Efficiently fetch teacher data to get the required email and name
    // Assumption: Teachers are stored in "Teachers" node with teacherId as key
    DatabaseReference dbReference =
        FirebaseDatabase.instance.ref().child("Teachers/$teacherId");
    final snapshot = await dbReference.get();

    if (!snapshot.exists || snapshot.value == null) {
      throw Exception(wrongCredentialsError);
    }

    // Decode and map the data
    Map<String, dynamic> userDataMap;
    User user;
    String email;
    String name;

    try {
      userDataMap = jsonDecode(jsonEncode(snapshot.value));
      // Ensure User model can handle flexible IDs or role-specific logging
      user = User.fromJson(userDataMap);
      email = user.email;
      name = user.fullname;
    } catch (e) {
      print('ERROR parsing teacher data: $e');
      throw Exception('Data error: Unable to parse teacher profile. ($e)');
    }

    if (email.isEmpty) {
      print(
          'ERROR: User profile found, but email field is empty for $teacherId.');
      throw Exception(wrongCredentialsError);
    }

    print('DEBUG: Attempting login for teacher email: $email');

    try {
      // 2. Validate password SECURELY using Firebase Authentication
      await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Successful login: Save state to Hive
      await _loginbox.put("isLoggedIn", true);
      await _loginbox.put("UserType", "Teacher"); // Used for routing
      await _loginbox.put("User", teacherId);
      await _loginbox.put("UserName", name);
      return;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Exception(wrongCredentialsError);
      }
      throw Exception('Login failed: ${e.message}');
    }
  }
}
