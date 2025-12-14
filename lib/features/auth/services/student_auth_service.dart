// lib/features/auth/services/student_auth_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:ace/features/auth/services/auth_service_interface.dart';
import 'package:ace/services/hive_constants.dart';
import 'package:ace/models/user.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class StudentAuthService implements AuthServiceInterface {
  final Box _loginbox = Hive.box("_loginbox");
  static const String wrongCredentialsError = 'Wrong username or password';

  @override
  Future<void> login({
    required String email, // Changed from id to email
    required String password,
  }) async {
    final String studentEmail = email.trim();

    try {
      // 1. Validate password SECURELY using Firebase Authentication
      // This now happens FIRST, avoiding unauthenticated database reads.
      final userCredential =
          await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: studentEmail,
        password: password,
      );

      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw Exception("Authentication successful but user is null.");
      }

      // 2. Fetch student data to get the ID and Name for the session
      // We query by email since we no longer have the ID upfront.
      // Rules allow this read because auth != null now.
      DatabaseReference dbReference =
          FirebaseDatabase.instance.ref().child("Students");

      final snapshot =
          await dbReference.orderByChild("email").equalTo(studentEmail).get();

      if (!snapshot.exists || snapshot.value == null) {
        // This is a critical edge case: Auth works, but no profile exists in DB.
        // Should probably logout to prevent ghost sessions.
        await fb_auth.FirebaseAuth.instance.signOut();
        throw Exception("User profile not found in database.");
      }

      // 3. Extract Profile Data
      // The result is a Map where keys are IDs (e.g. STU-001)
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      // We expect only one match since emails should be unique
      var entry = values.entries.first;
      String studentId = entry.key;
      Map<String, dynamic> userDataMap =
          jsonDecode(jsonEncode(entry.value)); // Ensure strictly string keys

      User user = User.fromJson(userDataMap);
      final String studentName = user.fullname;

      // 4. Successful login: Save state to Hive
      await _loginbox.put("isLoggedIn", true);
      await _loginbox.put(
          "UserType", "Student"); // <-- Ensures WrapperScreen works
      await _loginbox.put("User", studentId);
      await _loginbox.put("UserName", studentName);
      return;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle Auth errors
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Exception(wrongCredentialsError);
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      // Handle other errors (e.g. database failures)
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

  // --- CACHED USER STATS LOGIC ---
  Stream<Map<String, dynamic>> streamUserStatsCached(String studentId) async* {
    final box = Hive.box(HiveConstants.kStudentStatsBox);

    // 1. Yield Cache Immediately
    if (box.containsKey(studentId)) {
      final cachedMap = box.get(studentId);
      if (cachedMap != null) {
        // We know we stored Map<String, dynamic>
        // Depending on how Hive returns it (Map<dynamic, dynamic>), we might need casting
        final cleanMap = Map<String, dynamic>.from(cachedMap as Map);
        // Convert the 'user' sub-map back to a User object for the UI
        if (cleanMap['user'] is Map) {
          cleanMap['user'] =
              User.fromJson(Map<String, dynamic>.from(cleanMap['user'] as Map));
        } else if (cleanMap['user'] is String) {
          // If stored as JSON string (fallback)
          cleanMap['user'] = User.fromJson(jsonDecode(cleanMap['user']));
        }
        yield cleanMap;
      }
    }

    // 2. Fetch Fresh Data (Network)
    try {
      final freshData = await _fetchRichUserStats(studentId);

      // 3. Update Cache
      // We must serialize the 'User' object to plain JSON Map for Hive storage safely
      final cacheableData = Map<String, dynamic>.from(freshData);
      if (cacheableData['user'] is User) {
        cacheableData['user'] = (cacheableData['user'] as User).toJson();
      }

      await box.put(studentId, cacheableData);

      // 4. Yield Fresh Data
      yield freshData;
    } catch (e) {
      // If network fails, we rely on the cache yielded in step 1.
      print('Error fetching user stats: $e');
    }
  }

  // Helper method mirroring the logic originally in StudentAccountScreen
  Future<Map<String, dynamic>> _fetchRichUserStats(String studentId) async {
    // Reference assuming studentId is the key in "Students/studentId"
    // Note: The original code used 'fullname' as the key, but it SHOULD be studentId.
    // However, looking at the previous file, it used _loginbox.get("User") which IS the ID.
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("Students/$studentId");

    // Fetch user profile
    DataSnapshot snapshot = await databaseReference.get();
    if (!snapshot.exists || snapshot.value == null) {
      throw Exception("Student data not found for $studentId.");
    }

    Map<String, dynamic> myObj = jsonDecode(jsonEncode(snapshot.value));
    User myUserObj = User.fromJson(myObj);

    int enrolledClassesCount = 0;
    int pendingAssignments = 0;

    // Calculate Stats
    try {
      DataSnapshot classesSnapshot =
          await databaseReference.child('classes').get();
      if (classesSnapshot.exists && classesSnapshot.value is Map) {
        enrolledClassesCount = (classesSnapshot.value as Map).keys.length;

        // Pending assignments
        final classIds = (classesSnapshot.value as Map).keys.toList();
        for (var classId in classIds) {
          try {
            DataSnapshot classworkRefsSnapshot = await FirebaseDatabase.instance
                .ref()
                .child('Classes/$classId/classwork')
                .get();

            if (classworkRefsSnapshot.exists &&
                classworkRefsSnapshot.value is Map) {
              final classworkIds =
                  (classworkRefsSnapshot.value as Map).keys.toList();
              for (var classworkId in classworkIds) {
                // Check if student has submitted
                DataSnapshot submissionSnapshot = await FirebaseDatabase
                    .instance
                    .ref()
                    .child('submissions/$classworkId/$studentId')
                    .get();
                if (!submissionSnapshot.exists) {
                  pendingAssignments++;
                }
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    return {
      'user': myUserObj,
      'enrolledClasses': enrolledClassesCount,
      'pendingAssignments': pendingAssignments,
    };
  }
}
