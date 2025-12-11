// lib/services/grade_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:ace/services/hive_constants.dart';

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
  Future<bool> checkStudentExists(String studentIdInput) async {
    final studentId = studentIdInput.trim();
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
  Future<Map<String, dynamic>?> fetchStudentGrades(
      String studentIdInput) async {
    final studentId = studentIdInput.trim();
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
    required String gradeType, // 'Prelim', 'Midterm', 'Final' (or 'P1', etc.)
    required String gradeValue,
  }) async {
    final sId = studentId.trim();
    try {
      // 1. Reference to the specific subject
      final subjectRef = _gradesRef.child(sId).child(subjectCode);

      // 2. Fetch current grades first to perform calculation
      final snapshot = await subjectRef.get();
      Map<String, dynamic> currentGrades = {};

      if (snapshot.exists && snapshot.value != null) {
        currentGrades =
            Map<String, dynamic>.from(jsonDecode(jsonEncode(snapshot.value)));
      }

      // 3. Update the map with the NEW value
      currentGrades[gradeType] = gradeValue;

      // 4. Calculate Final Grade AUTOMATICALLY if we have all 3 inputs
      // Check keys based on your new naming convention: 'Prelim', 'Midterm', 'Final'
      // Or fallback to 'P1', 'P2', 'P3' if using legacy.
      // 4. Calculate Final Grade AUTOMATICALLY if we have all 3 inputs
      // Check keys based on your new naming convention: 'Prelim', 'Midterm', 'Final'

      // Try parsing keys. Adjust these keys to match exactly what your dropdown sends.
      final p1 = double.tryParse(currentGrades['Prelim']?.toString() ??
          currentGrades['P1']?.toString() ??
          '');
      final p2 = double.tryParse(currentGrades['Midterm']?.toString() ??
          currentGrades['P2']?.toString() ??
          '');
      final p3 = double.tryParse(currentGrades['Final']?.toString() ??
          currentGrades['P3']?.toString() ??
          '');

      // Only calculate if we have valid numbers for all 3
      if (p1 != null && p2 != null && p3 != null) {
        final average = (p1 + p2 + p3) / 3;
        // Save this as 'Average' to distinguish from the Final Term Grade.
        currentGrades['Average'] = average.toStringAsFixed(2);
      }

      // 5. Save the entire updated map for this subject
      await subjectRef.set(currentGrades);

      if (kDebugMode) {
        print('Grades updated for $sId in $subjectCode: $currentGrades');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating grade: $e');
      }
      rethrow;
    }
  }

  /// **NEW: Cached Stream Strategy**
  /// 1. Immediately emit cached data from Hive (if available).
  /// 2. Listen to Firebase and emit new data + update Hive on change.
  Stream<Map<String, dynamic>> getStudentGradesStreamCached(
      String studentId) async* {
    final box = Hive.box(HiveConstants.kGradesBox);

    // 1. Emit Check Cache first
    if (box.containsKey(studentId)) {
      final cachedData = box.get(studentId);
      if (cachedData is Map) {
        yield Map<String, dynamic>.from(cachedData);
      }
    }

    // 2. Listen to Network
    yield* _gradesRef.child(studentId).onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        // Safe decode
        final raw = event.snapshot.value;
        // Handling the dynamic -> Map specific to this project structure
        final data = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;

        // Update Cache
        box.put(studentId, data);

        return data;
      }
      return <String, dynamic>{};
    });
  }
}
