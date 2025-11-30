// lib/services/class_service.dart

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/classroom.dart';

class ClassService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // --- Utility Methods ---

  // 1. Check if a student ID exists
  Future<bool> checkStudentExists(String studentId) async {
    final snapshot = await _db.child('Students/$studentId').get();
    // Student exists if the node exists (even if it has no classes yet)
    return snapshot.exists && snapshot.value != null;
  }

  // --- Enrollment Management ---

  // 2. Enroll a student in a specific class
  Future<void> enrollStudentInClass(String studentId, String classId) async {
    // Path: Students/{studentId}/classes/{classId}
    final enrollmentRef = _db.child('Students/$studentId/classes/$classId');

    // Setting a simple 'true' value is efficient for checking existence later
    await enrollmentRef.set(true);
  }

  // 3. Unenroll a student from a class (optional, but good practice)
  Future<void> unenrollStudentFromClass(
      String studentId, String classId) async {
    await _db.child('Students/$studentId/classes/$classId').remove();
  }

  // --- Data Retrieval ---

  // 4. Fetch all available classes (for the admin to choose from)
  Future<List<Classroom>> fetchAllAvailableClasses() async {
    final snapshot = await _db.child('Classes').get();
    List<Classroom> classes = [];

    if (snapshot.exists && snapshot.value is Map) {
      final Map<String, dynamic> classMap =
          jsonDecode(jsonEncode(snapshot.value));

      classMap.forEach((classId, classData) {
        try {
          classes.add(Classroom.fromJson(classId, classData));
        } catch (e) {
          print('Error parsing class $classId: $e');
        }
      });
    }

    // Fallback: If no classes in DB, use mock data.
    return classes.isNotEmpty ? classes : mockClassroomList;
  }

  // 5. Fetch a student's currently enrolled classes
  // This fetches the full Class objects based on the IDs stored under the student node.
  Future<List<Classroom>> fetchStudentClasses(String studentId) async {
    // 5a. Get the list of class IDs the student is enrolled in
    final studentClassesSnapshot =
        await _db.child('Students/$studentId/classes').get();

    if (!studentClassesSnapshot.exists ||
        studentClassesSnapshot.value == null) {
      return []; // Student is enrolled in no classes
    }

    final Map<String, dynamic> enrolledIdsMap =
        jsonDecode(jsonEncode(studentClassesSnapshot.value));

    final List<String> enrolledClassIds = enrolledIdsMap.keys.toList();

    if (enrolledClassIds.isEmpty) return [];

    // 5b. Fetch the full class details for each ID
    List<Classroom> studentClasses = [];
    final allClassesSnapshot = await _db.child('Classes').get();

    if (allClassesSnapshot.exists && allClassesSnapshot.value is Map) {
      final Map<String, dynamic> allClassesMap =
          jsonDecode(jsonEncode(allClassesSnapshot.value));

      for (String id in enrolledClassIds) {
        if (allClassesMap.containsKey(id)) {
          studentClasses.add(Classroom.fromJson(id, allClassesMap[id]));
        }
      }
    }

    // Fallback: If we couldn't fetch details from DB, use mock list filtering
    if (studentClasses.isEmpty) {
      return mockClassroomList
          .where((c) => enrolledClassIds.contains(c.classId))
          .toList();
    }

    return studentClasses;
  }
}
