// admin_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'dart:convert';

class AdminAuthService {
  // Point to the Admin database node
  final DatabaseReference _dbReference =
      FirebaseDatabase.instance.ref().child("Admins/");

  // NOTE: Assuming the Hive box is already open (as in main.dart)
  final Box _loginbox = Hive.box("_loginbox");

  static const String wrongCredentialsError = 'Wrong username or password';

  Future<void> login({
    required String adminId, // Using adminId here
    required String password,
  }) async {
    // 1. Fetch data from the 'Admins/' path
    final snapshot = await _dbReference.get();

    if (!snapshot.exists) {
      throw Exception('No admin data found.');
    }

    bool userFound = false;

    // Firebase data iteration
    for (final data in snapshot.children) {
      if (data.key == adminId) {
        userFound = true;

        // Convert Firebase data to a Map and then to the User model
        Map<String, dynamic> userDataMap = jsonDecode(jsonEncode(data.value));
        User user = User.fromJson(userDataMap);

        // 2. Validate password
        if (user.password == password) {
          // 3. Successful login: Save state to Hive, maybe using a different key or value for admin
          await _loginbox.put("isLoggedIn", true);
          await _loginbox.put("UserType", "Admin"); // Indicate user type
          await _loginbox.put("User", adminId);
          return; // Success
        } else {
          throw Exception(wrongCredentialsError);
        }
      }
    }

    if (!userFound) {
      throw Exception(wrongCredentialsError);
    }
  }
}
