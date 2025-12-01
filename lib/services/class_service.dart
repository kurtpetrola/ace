// lib/services/class_service.dart

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/user.dart';

// Mock list of User objects for demonstration
final List<User> mockStudentRoster = [
  User(
      userId: 'STU-101',
      fullname: 'Alice Johnson',
      email: 'a@j.com',
      age: 20,
      department: 'CS',
      gender: 'F',
      role: 'student'),
  User(
      userId: 'STU-102',
      fullname: 'Bob Williams',
      email: 'b@w.com',
      age: 21,
      department: 'MATH',
      gender: 'M',
      role: 'student'),
  User(
      userId: 'STU-103',
      fullname: 'Charlie Brown',
      email: 'c@b.com',
      age: 19,
      department: 'ENG',
      gender: 'M',
      role: 'student'),
];

// Example static list used as a temporary mock for demonstration purposes
final List<Classroom> mockClassroomList = [
  Classroom(
    classId: 'MATH101',
    className: 'Calculus I',
    description: 'Introduction to Derivatives and Integrals.',
    creator: 'Dr. Evelyn Reed',
    bannerImgPath: 'assets/images/banner/banner1.jpg',
  ),
  Classroom(
    classId: 'CS201',
    className: 'Data Structures',
    description: 'Arrays, Linked Lists, and Trees.',
    creator: 'Prof. Alan Turing',
    bannerImgPath: 'assets/images/banner/banner2.jpg',
  ),
];

class ClassService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // --- Utility Methods ---

  // 1. Check if a student ID exists
  Future<bool> checkStudentExists(String studentId) async {
    // Note: Assuming student profiles are stored under 'Students' or 'Users'
    final studentSnapshot = await _db.child('Students/$studentId').get();
    return studentSnapshot.exists && studentSnapshot.value != null;
  }

  // --- Enrollment Management ---

  // 2. Enroll a student in a specific class (Performs Bidirectional Update)
  Future<void> enrollStudentInClass(String studentId, String classId) async {
    final updates = <String, dynamic>{
      // Path 1: Update the student's list of classes
      'Students/$studentId/classes/$classId': true,
      // Path 2: Update the class's roster of students (REQUIRED for Roster Management)
      'Classes/$classId/students/$studentId': true,
    };
    await _db.update(updates);
  }

  // 3. Unenroll a student from a class (Performs Bidirectional Update)
  Future<void> unenrollStudentFromClass(
      String studentId, String classId) async {
    final updates = <String, dynamic>{
      // Path 1: Remove from the student's list
      'Students/$studentId/classes/$classId': null,
      // Path 2: Remove from the class's roster
      'Classes/$classId/students/$studentId': null,
    };
    await _db.update(updates);
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

  // 6. Create a new class and save it to Firebase
  Future<void> createNewClass(Classroom newClass) async {
    // We push to the 'Classes' node, which generates a unique key (classId)
    await _db.child('Classes').push().set(newClass.toFirebaseJson());
  }

  // 7. NEW METHOD: Fetch the full User objects for all students in a class roster
  Future<List<User>> fetchStudentsInClass(String classId) async {
    // 7a. Get the list of student IDs for the class from the Class node
    final rosterSnapshot = await _db.child('Classes/$classId/students').get();

    if (!rosterSnapshot.exists || rosterSnapshot.value == null) {
      return []; // No students enrolled
    }

    final Map<String, dynamic> enrolledIdsMap =
        jsonDecode(jsonEncode(rosterSnapshot.value));

    final List<String> enrolledStudentIds = enrolledIdsMap.keys.toList();

    if (enrolledStudentIds.isEmpty) return [];

    // 7b. Fetch all student profiles from the 'Students' node
    final allStudentsSnapshot = await _db.child('Students').get();
    List<User> studentRoster = [];

    if (allStudentsSnapshot.exists && allStudentsSnapshot.value is Map) {
      final Map<String, dynamic> allStudentsMap =
          jsonDecode(jsonEncode(allStudentsSnapshot.value));

      for (String id in enrolledStudentIds) {
        if (allStudentsMap.containsKey(id)) {
          final studentData = allStudentsMap[id];
          if (studentData is Map<String, dynamic>) {
            try {
              // Assuming User.fromJson requires the 'userId' field
              studentRoster.add(User.fromJson({...studentData, 'userId': id}));
            } catch (e) {
              print('Error parsing User $id: $e');
            }
          }
        }
      }
    }

    // Fallback/Mock for testing:
    if (studentRoster.isEmpty) {
      return mockStudentRoster
          .where((u) => enrolledStudentIds.contains(u.userId))
          .toList();
    }

    return studentRoster;
  }
}
