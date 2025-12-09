// lib/models/submission.dart

class Submission {
  final String submissionId;
  final String classworkId;
  final String studentId;
  final String answerText;
  final String? attachmentUrl;
  final DateTime submittedAt;
  final int? grade;

  Submission({
    required this.submissionId,
    required this.classworkId,
    required this.studentId,
    required this.answerText,
    this.attachmentUrl,
    required this.submittedAt,
    this.grade,
  });

  Map<String, dynamic> toMap() => {
        'submissionId': submissionId,
        'classworkId': classworkId,
        'studentId': studentId,
        'answerText': answerText,
        'attachmentUrl': attachmentUrl,
        'submittedAt': submittedAt.toIso8601String(),
        'grade': grade,
      };

  factory Submission.fromMap(Map<dynamic, dynamic> map,
      {String? studentIdOverride}) {
    return Submission(
      submissionId: map['submissionId'],
      classworkId: map['classworkId'],
      studentId: studentIdOverride ?? map['studentId'],
      answerText: map['answerText'],
      attachmentUrl: map['attachmentUrl'],
      submittedAt: DateTime.parse(map['submittedAt']),
      grade: map['grade'] as int?,
    );
  }
}
