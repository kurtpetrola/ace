// student_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'dart:convert';

class StudentAuthService {
  final DatabaseReference _dbReference =
      FirebaseDatabase.instance.ref().child("Students/");
  final Box _loginbox = Hive.box("_loginbox");

  // Custom exception for failed login
  static const String wrongCredentialsError = 'Wrong username or password';

  Future<void> login({
    required String studentId,
    required String password,
  }) async {
    // 1. Fetch data from the 'Students/' path
    final snapshot = await _dbReference.get();

    if (!snapshot.exists || snapshot.children.isEmpty) {
      throw Exception('No student data found.');
    }

    bool userFound = false;

    for (final data in snapshot.children) {
      // Check if the current Firebase key matches the entered studentId
      if (data.key == studentId) {
        userFound = true;
        // Firebase data is often an Object, we use jsonEncode/Decode to convert it
        // into a type-safe Map<String, dynamic> for the User model.
        Map<String, dynamic> userDataMap = jsonDecode(jsonEncode(data.value));
        User user = User.fromJson(userDataMap);

        // 2. Validate password
        if (user.password == password) {
          // 3. Successful login: Save state to Hive
          await _loginbox.put("isLoggedIn", true);
          await _loginbox.put("User", studentId);
          return; // Success, exit method
        } else {
          // Password mismatch
          throw Exception(wrongCredentialsError);
        }
      }
    }

    // If the loop finishes without finding the user ID
    if (!userFound) {
      throw Exception(wrongCredentialsError);
    }
  }
}
