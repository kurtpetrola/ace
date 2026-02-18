// lib/services/user_service.dart

import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/user.dart';

class UserService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Fetch all students from the 'Students' node
  Future<List<User>> fetchAllStudents() async {
    final snapshot = await _db.child('Students').get();
    final List<User> students = [];

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
          log('Error parsing student $studentId: $e');
        }
      });
    }
    return students;
  }

  // Fetch all admins from the 'Admins' node
  Future<List<User>> fetchAllAdmins() async {
    final snapshot = await _db.child('Admins').get();
    final List<User> admins = [];

    if (snapshot.exists && snapshot.value is Map) {
      final Map<String, dynamic> adminsMap =
          jsonDecode(jsonEncode(snapshot.value));

      adminsMap.forEach((adminId, userData) {
        try {
          if (userData is Map) {
            final Map<String, dynamic> data =
                Map<String, dynamic>.from(userData);

            // Ensure the key is used as the ID
            if (!data.containsKey('adminid')) {
              data['adminid'] = adminId;
            }
            admins.add(User.fromJson(data));
          }
        } catch (e) {
          log('Error parsing admin $adminId: $e');
        }
      });
    }
    return admins;
  }

  // Fetch all teachers from the 'Teachers' node
  Future<List<User>> fetchAllTeachers() async {
    final snapshot = await _db.child('Teachers').get();
    final List<User> teachers = [];

    if (snapshot.exists && snapshot.value is Map) {
      final Map<String, dynamic> teachersMap =
          jsonDecode(jsonEncode(snapshot.value));

      teachersMap.forEach((teacherId, userData) {
        try {
          if (userData is Map) {
            final Map<String, dynamic> data =
                Map<String, dynamic>.from(userData);

            if (!data.containsKey('teacherid')) {
              data['teacherid'] = teacherId;
            }
            teachers.add(User.fromJson(data));
          }
        } catch (e) {
          log('Error parsing teacher $teacherId: $e');
        }
      });
    }
    return teachers;
  }

  // Update a user's profile data in the database
  Future<void> updateUser(User user) async {
    // Determine the path based on the role
    String path;
    if (user.role == 'admin') {
      path = 'Admins/${user.userId}';
    } else if (user.role == 'teacher') {
      path = 'Teachers/${user.userId}';
    } else {
      path = 'Students/${user.userId}';
    }

    // Convert to JSON, but remove the ID fields as they are part of the path key
    // The email is also generally fixed in Firebase Auth.
    final Map<String, dynamic> updateData = user.toJson();
    updateData
        .removeWhere((key, value) => key.endsWith('id') || key == 'email');

    await _db.child(path).update(updateData);
  }

  // Mock function for handling password reset
  Future<void> resetUserPassword(String email) async {
    // NOTE: This is a placeholder. Real password reset requires Firebase Auth
    // or an Admin SDK, which is not directly available in this Flutter client setup.

    log('Attempting to reset password for email: $email');
    await Future.delayed(const Duration(seconds: 1));

    // Simulate success based on a simple check
    if (email.contains('@')) {
      log('Password reset initiated for $email');
      return Future.value();
    } else {
      throw Exception('Invalid email format. Password reset failed.');
    }
  }

  // Check if a teacher ID already exists
  Future<bool> checkTeacherIdExists(String teacherId) async {
    final snapshot = await _db.child('Teachers/$teacherId').get();
    return snapshot.exists;
  }

  // Fetch a single teacher by ID
  Future<User?> getTeacher(String teacherId) async {
    final snapshot = await _db.child('Teachers/$teacherId').get();
    if (snapshot.exists && snapshot.value is Map) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);
      if (!data.containsKey('teacherid')) {
        data['teacherid'] = teacherId;
      }
      return User.fromJson(data);
    }
    return null;
  }
}
