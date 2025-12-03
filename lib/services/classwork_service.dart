// lib/services/classwork_service.dart

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/classwork.dart';

class ClassworkService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // --- CREATE Operations ---
  /// Creates a new classwork and associates it with a class
  Future<String?> createClasswork(Classwork classwork) async {
    try {
      final classworkRef = _db.child('Classwork').push();
      final classworkId = classworkRef.key!;

      final classworkData = classwork.toFirebaseJson();

      final updates = <String, dynamic>{
        'Classwork/$classworkId': classworkData,
        'Classes/${classwork.classId}/classwork/$classworkId': true,
      };

      await _db.update(updates);
      return classworkId;
    } catch (e) {
      print('Error creating classwork: $e');
      return null;
    }
  }

  // --- READ Operations ---
  Future<List<Classwork>> fetchClassworkForClass(String classId) async {
    try {
      final classworkIdsSnapshot =
          await _db.child('Classes/$classId/classwork').get();

      if (!classworkIdsSnapshot.exists || classworkIdsSnapshot.value == null) {
        return [];
      }

      if (classworkIdsSnapshot.value is String) return [];

      final Map<String, dynamic> classworkIdsMap =
          jsonDecode(jsonEncode(classworkIdsSnapshot.value));

      final List<String> classworkIds = classworkIdsMap.keys.toList();
      if (classworkIds.isEmpty) return [];

      final allClassworkSnapshot = await _db.child('Classwork').get();
      if (!allClassworkSnapshot.exists ||
          allClassworkSnapshot.value == null ||
          allClassworkSnapshot.value is String) return [];

      final Map<String, dynamic> allClassworkMap =
          jsonDecode(jsonEncode(allClassworkSnapshot.value));

      List<Classwork> classworkList = [];
      for (String id in classworkIds) {
        if (allClassworkMap.containsKey(id)) {
          try {
            classworkList.add(Classwork.fromJson(id, allClassworkMap[id]));
          } catch (e) {
            print('Error parsing classwork $id: $e');
          }
        }
      }

      classworkList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return classworkList;
    } catch (e) {
      print('Error fetching classwork for class $classId: $e');
      return [];
    }
  }

  Future<Classwork?> fetchClassworkById(String classworkId) async {
    try {
      final snapshot = await _db.child('Classwork/$classworkId').get();
      if (!snapshot.exists || snapshot.value == null) return null;

      final Map<String, dynamic> data = jsonDecode(jsonEncode(snapshot.value));
      return Classwork.fromJson(classworkId, data);
    } catch (e) {
      print('Error fetching classwork by ID $classworkId: $e');
      return null;
    }
  }

  Future<List<Classwork>> fetchClassworkForStudent(String studentId) async {
    try {
      final studentClassesSnapshot =
          await _db.child('Students/$studentId/classes').get();

      if (!studentClassesSnapshot.exists ||
          studentClassesSnapshot.value == null) {
        return [];
      }

      final Map<String, dynamic> enrolledClassesMap =
          jsonDecode(jsonEncode(studentClassesSnapshot.value));

      List<Classwork> allClasswork = [];
      for (String classId in enrolledClassesMap.keys) {
        final classwork = await fetchClassworkForClass(classId);
        allClasswork.addAll(classwork);
      }

      allClasswork.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

      return allClasswork;
    } catch (e) {
      print('Error fetching classwork for student $studentId: $e');
      return [];
    }
  }

  // --- UPDATE Operations ---
  Future<bool> updateClasswork(Classwork classwork) async {
    try {
      final data = classwork.toFirebaseJson();
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _db.child('Classwork/${classwork.classworkId}').update(data);
      return true;
    } catch (e) {
      print('Error updating classwork ${classwork.classworkId}: $e');
      return false;
    }
  }

  // --- DELETE Operations ---
  Future<bool> deleteClasswork(String classworkId, String classId) async {
    try {
      final updates = <String, dynamic>{
        'Classwork/$classworkId': null,
        'Classes/$classId/classwork/$classworkId': null,
      };
      await _db.update(updates);
      return true;
    } catch (e) {
      print('Error deleting classwork $classworkId: $e');
      return false;
    }
  }

  // --- ANALYTICS / UTILITY ---
  Future<int> getClassworkCount(String classId) async {
    final classwork = await fetchClassworkForClass(classId);
    return classwork.length;
  }

  Future<List<Classwork>> getUpcomingClasswork(String classId) async {
    final allClasswork = await fetchClassworkForClass(classId);
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return allClasswork
        .where((cw) =>
            cw.dueDate != null &&
            cw.dueDate!.isAfter(now) &&
            cw.dueDate!.isBefore(weekFromNow))
        .toList();
  }

  Future<List<Classwork>> getOverdueClasswork(String classId) async {
    final allClasswork = await fetchClassworkForClass(classId);
    return allClasswork.where((cw) => cw.isOverdue).toList();
  }
}
