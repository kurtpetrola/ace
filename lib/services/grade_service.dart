// lib/services/grade_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class GradeService {
  // Path for grades: /StudentGrades
  final DatabaseReference _gradesRef =
      FirebaseDatabase.instance.ref().child('StudentGrades');

  // Path for student profiles (ASSUMPTION: /Students)
  final DatabaseReference _studentsRef =
      FirebaseDatabase.instance.ref().child('Students');

  // ------------------------------------------------------------------
  // NEW: Check for Student Profile Existence
  // ------------------------------------------------------------------
  /// Checks if a student profile exists under the /Students/{studentId} path.
  Future<bool> checkStudentExists(String studentId) async {
    try {
      final snapshot = await _studentsRef.child(studentId).get();
      // If the snapshot exists, the student profile is confirmed to exist.
      return snapshot.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking student existence for $studentId: $e');
      }
      return false;
    }
  }
  // ------------------------------------------------------------------

  /// Fetches a single student's grades by their student ID.
  /// Returns a Map<String, dynamic> where keys are subject codes (e.g., 'ITE 115').
  Future<Map<String, dynamic>?> fetchStudentGrades(String studentId) async {
    try {
      final snapshot = await _gradesRef.child(studentId).get();
      if (snapshot.exists && snapshot.value != null) {
        // Firebase snapshot value needs to be safely cast/encoded
        final data = jsonDecode(jsonEncode(snapshot.value));
        return data as Map<String, dynamic>;
      }
      return null; // Student found (via existence check), but no grades yet
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching grades for $studentId: $e');
      }
      return null;
    }
  }

  /// Updates a specific grade for a student in the database.
  /// Structure: /StudentGrades/{studentId}/{subjectCode}/{gradeType}
  Future<void> updateStudentGrade({
    required String studentId,
    required String subjectCode,
    required String gradeType, // e.g., 'P1', 'P2', 'Final'
    required String gradeValue, // e.g., '95', '78'
  }) async {
    try {
      // The update path for a specific grade
      final path = '$subjectCode/$gradeType';

      // Use .set() to set the specified field
      await _gradesRef.child(studentId).child(path).set(gradeValue);

      if (kDebugMode) {
        print(
            'Grade updated successfully for $studentId: $subjectCode/$gradeType = $gradeValue');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating grade: $e');
      }
      rethrow;
    }
  }

  /// Provides a stream of real-time grade updates for a specific student ID.
  Stream<DatabaseEvent> getStudentGradesStream(String studentId) {
    return _gradesRef.child(studentId).onValue;
  }
}
