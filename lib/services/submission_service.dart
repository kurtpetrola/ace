// lib/services/submission_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/submission.dart';

class SubmissionService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Create or overwrite a student's submission
  Future<void> submitSubmission(Submission submission) async {
    final ref = _db
        .child('submissions')
        .child(submission.classworkId)
        .child(submission.studentId);

    await ref.set(submission.toMap());
  }

  /// Check if a student already submitted
  Future<Submission?> getStudentSubmission(
      String classworkId, String studentId) async {
    final snapshot = await _db
        .child('submissions')
        .child(classworkId)
        .child(studentId)
        .get();

    if (!snapshot.exists || snapshot.value == null) return null;

    final map = Map<String, dynamic>.from(snapshot.value as Map);
    return Submission.fromMap(map);
  }

  /// Fetch submissions for a classwork (for admin detailed view)
  Future<List<Submission>> fetchSubmissionsForClasswork(
      String classworkId) async {
    final snapshot = await _db.child('submissions').child(classworkId).get();
    if (!snapshot.exists) return [];
    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries
        .map((e) =>
            Submission.fromMap(e.value, studentIdOverride: e.key.toString()))
        .toList();
  }

  /// Real-time stream of submission counts
  Stream<int> submissionsCountStream(String classworkId) {
    final ref = _db.child('submissions').child(classworkId);
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return data?.length ?? 0;
    });
  }
}
