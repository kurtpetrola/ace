// lib/services/user_service.dart

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/user.dart';

class UserService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Fetch all students from the 'Students' node
  Future<List<User>> fetchAllStudents() async {
    final snapshot = await _db.child('Students').get();
    List<User> students = [];

    if (snapshot.exists && snapshot.value is Map) {
      // Use jsonEncode/jsonDecode to safely convert the dynamic Map to Map<String, dynamic>
      final Map<String, dynamic> studentsMap =
          jsonDecode(jsonEncode(snapshot.value));

      studentsMap.forEach((studentId, userData) {
        try {
          if (userData is Map) {
            final Map<String, dynamic> data =
                Map<String, dynamic>.from(userData);

            // The Firebase key (studentId) is the actual ID, ensure it's in the data map
            // for the User.fromJson factory to use it as 'studentid'.
            if (!data.containsKey('studentid')) {
              data['studentid'] = studentId;
            }
            students.add(User.fromJson(data));
          }
        } catch (e) {
          print('Error parsing student $studentId: $e');
        }
      });
    }
    return students;
  }

  // Update a user's profile data in the database
  Future<void> updateUser(User user) async {
    // Determine the path based on the role
    String path = user.role == 'admin'
        ? 'Admins/${user.userId}'
        : 'Students/${user.userId}';

    // Convert to JSON, but remove the ID fields as they are part of the path key
    // The email is also generally fixed in Firebase Auth.
    Map<String, dynamic> updateData = user.toJson();
    updateData
        .removeWhere((key, value) => key.endsWith('id') || key == 'email');

    await _db.child(path).update(updateData);
  }

  // Mock function for handling password reset
  Future<void> resetUserPassword(String email) async {
    // NOTE: This is a placeholder. Real password reset requires Firebase Auth
    // or an Admin SDK, which is not directly available in this Flutter client setup.

    print('Attempting to reset password for email: $email');
    await Future.delayed(const Duration(seconds: 1));

    // Simulate success based on a simple check
    if (email.contains('@')) {
      print('Password reset initiated for $email');
      return Future.value();
    } else {
      throw Exception('Invalid email format. Password reset failed.');
    }
  }
}
