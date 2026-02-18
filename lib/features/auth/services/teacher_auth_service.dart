// lib/features/auth/services/teacher_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/features/auth/services/auth_service_interface.dart';
import 'package:ace/models/user.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class TeacherAuthService implements AuthServiceInterface {
  final Box _loginbox = Hive.box('_loginbox');
  static const String wrongCredentialsError = 'Wrong username or password';

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final String teacherEmail = email.trim();

    try {
      // 1. Validate password SECURELY using Firebase Authentication
      final userCredential =
          await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: teacherEmail,
        password: password,
      );

      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw Exception('Authentication successful but user is null.');
      }

      // 2. Fetch teacher data to get the ID and Name for the session
      // Query by email.
      final DatabaseReference dbReference =
          FirebaseDatabase.instance.ref().child('Teachers');

      final snapshot =
          await dbReference.orderByChild('email').equalTo(teacherEmail).get();

      if (!snapshot.exists || snapshot.value == null) {
        await fb_auth.FirebaseAuth.instance.signOut();
        throw Exception('User profile not found in database.');
      }

      // 3. Extract Profile Data
      final Map<dynamic, dynamic> values =
          snapshot.value as Map<dynamic, dynamic>;
      final entry = values.entries.first;
      final String teacherId = entry.key;
      final Map<String, dynamic> userDataMap =
          jsonDecode(jsonEncode(entry.value));

      final User user = User.fromJson(userDataMap);
      final String teacherName = user.fullname;

      // 4. Successful login: Save state to Hive
      await _loginbox.put('isLoggedIn', true);
      await _loginbox.put('UserType', 'Teacher');
      await _loginbox.put('User', teacherId);
      await _loginbox.put('UserName', teacherName);
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

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await fb_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email.');
      }
      throw Exception(e.message ?? 'Failed to send reset email.');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
