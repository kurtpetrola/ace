// lib/services/class_service.dart

import 'dart:async';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/user.dart';
import 'package:hive/hive.dart';
import 'package:ace/services/hive_constants.dart';

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

  // Stream for a specific teacher's classes
  Stream<List<Classroom>> streamTeacherClasses(String teacherId) {
    return _db
        .child('Classes')
        .orderByChild('teacherId')
        .equalTo(teacherId)
        .onValue
        .map((event) {
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
    try {
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

      // Cache the result
      final box = Hive.box(HiveConstants.kClassBox);
      await box.put(studentId, result);

      return result;
    } catch (e) {
      // Fallback to cache if network fails
      final box = Hive.box(HiveConstants.kClassBox);
      if (box.containsKey(studentId)) {
        final cachedClasses = box.get(studentId);
        if (cachedClasses is List) {
          return cachedClasses.cast<Classroom>();
        }
      }
      return [];
    }
  }

  // STREAM with CACHE Strategy
  Stream<List<Classroom>> streamStudentClassesCached(String studentId) async* {
    final box = Hive.box(HiveConstants.kClassBox);

    // 1. Yield Cache
    if (box.containsKey(studentId)) {
      final cached = box.get(studentId);
      if (cached is List) {
        yield cached.cast<Classroom>();
      }
    }

    // 2. Fetch Network (Reuse existing logic which also updates cache)
    try {
      final freshData = await fetchStudentClasses(studentId);
      yield freshData;
    } catch (e) {
      // If network fails, we've already yielded cache above.
    }
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

  // DELETE CLASS (CASCADING)
  Future<void> deleteClass(String classId) async {
    // 1. Fetch Students to Unenroll
    final students = await fetchStudentsInClass(classId);

    // 2. Fetch Classwork to Delete
    // Note: We need to manually fetch classwork IDs from Classes/classId/classwork first
    final classworkSnap = await _db.child('Classes/$classId/classwork').get();
    List<String> classworkIds = [];
    if (classworkSnap.exists && classworkSnap.value != null) {
      final map = Map<String, dynamic>.from(classworkSnap.value as Map);
      classworkIds = map.keys.toList();
    }

    final Map<String, dynamic> updates = {};

    // A. Removals for Students (Unenroll)
    for (var student in students) {
      updates['Students/${student.userId}/classes/$classId'] = null;
    }

    // B. Removals for Notifications
    // Iterate through students and find notifications related to this class
    await Future.forEach(students, (User student) async {
      try {
        final notifSnap = await _db
            .child('Notifications/${student.userId}')
            .orderByChild('classId')
            .equalTo(classId)
            .get();

        if (notifSnap.exists && notifSnap.value != null) {
          final notifMap = Map<String, dynamic>.from(notifSnap.value as Map);
          for (var key in notifMap.keys) {
            updates['Notifications/${student.userId}/$key'] = null;
          }
        }
      } catch (e) {
        log('Error fetching notifications for cleanup: $e');
      }
    });

    // C. Removals for Classwork (Global Node) & Submissions
    for (var cwId in classworkIds) {
      updates['Classwork/$cwId'] = null;
      // Also delete all submissions for this classwork
      updates['submissions/$cwId'] = null;
    }

    // D. Remove Class Node
    updates['Classes/$classId'] = null;

    // Execute atomic update
    await _db.update(updates);
  }
}
