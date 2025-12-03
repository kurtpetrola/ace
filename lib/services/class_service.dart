// lib/services/class_service.dart

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/user.dart';

class ClassService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // STUDENTS

  Future<bool> checkStudentExists(String studentId) async {
    final snapshot = await _db.child('Students/$studentId').get();
    return snapshot.exists && snapshot.value != null;
  }

  // CLASSES — REALTIME

  // Realtime stream — reacts immediately to new classes
  Stream<List<Classroom>> streamAllClasses() {
    return _db.child('Classes').onValue.map((event) {
      final snap = event.snapshot;

      if (!snap.exists || snap.value == null) return [];

      final Map<String, dynamic> raw =
          Map<String, dynamic>.from(snap.value as Map);

      return raw.entries.map((entry) {
        return Classroom.fromJson(
          entry.key,
          Map<String, dynamic>.from(entry.value),
        );
      }).toList();
    });
  }

  // CREATE CLASS

  // Generates correct Firebase key
  Future<void> createNewClass(Classroom newClass) async {
    final ref = _db.child('Classes').push();

    await ref.set(newClass.toFirebaseJson());
  }

  // ENROLLMENT (BIDIRECTIONAL)

  Future<void> enrollStudentInClass(String studentId, String classId) async {
    await _db.update({
      'Students/$studentId/classes/$classId': true,
      'Classes/$classId/students/$studentId': true,
    });
  }

  Future<void> unenrollStudentFromClass(
      String studentId, String classId) async {
    await _db.update({
      'Students/$studentId/classes/$classId': null,
      'Classes/$classId/students/$studentId': null,
    });
  }

  // STUDENT → CLASSES

  Future<List<Classroom>> fetchStudentClasses(String studentId) async {
    final classesSnap = await _db.child('Students/$studentId/classes').get();

    if (!classesSnap.exists || classesSnap.value == null) {
      return [];
    }

    final Map<String, dynamic> idMap =
        Map<String, dynamic>.from(classesSnap.value as Map);

    final allClassesSnap = await _db.child('Classes').get();
    if (!allClassesSnap.exists || allClassesSnap.value == null) return [];

    final Map<String, dynamic> all =
        Map<String, dynamic>.from(allClassesSnap.value as Map);

    final List<Classroom> result = [];

    for (final id in idMap.keys) {
      if (all.containsKey(id)) {
        result.add(Classroom.fromJson(
          id,
          Map<String, dynamic>.from(all[id]),
        ));
      }
    }

    return result;
  }

  // CLASS → STUDENTS (ROSTER)

  Future<List<User>> fetchStudentsInClass(String classId) async {
    final rosterSnap = await _db.child('Classes/$classId/students').get();

    if (!rosterSnap.exists || rosterSnap.value == null) return [];

    final Map<String, dynamic> idMap =
        Map<String, dynamic>.from(rosterSnap.value as Map);

    final studentsSnap = await _db.child('Students').get();
    if (!studentsSnap.exists || studentsSnap.value == null) return [];

    final Map<String, dynamic> allStudents =
        Map<String, dynamic>.from(studentsSnap.value as Map);

    final List<User> roster = [];

    for (final id in idMap.keys) {
      if (allStudents.containsKey(id)) {
        roster.add(User.fromJson({
          ...Map<String, dynamic>.from(allStudents[id]),
          'userId': id,
        }));
      }
    }

    return roster;
  }
}
