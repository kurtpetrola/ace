// lib/features/teacher_dashboard/presentation/teacher_classwork_grades_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/models/user.dart';
import 'package:ace/models/submission.dart';
import 'package:ace/services/class_service.dart';
import 'package:ace/services/submission_service.dart';

class TeacherClassworkGradesScreen extends StatefulWidget {
  final Classroom classroom;
  final Classwork classwork;

  const TeacherClassworkGradesScreen({
    super.key,
    required this.classroom,
    required this.classwork,
  });

  @override
  State<TeacherClassworkGradesScreen> createState() =>
      _TeacherClassworkGradesScreenState();
}

class _TeacherClassworkGradesScreenState
    extends State<TeacherClassworkGradesScreen> {
  final ClassService _classService = ClassService();
  final SubmissionService _submissionService = SubmissionService();

  List<User> _students = [];
  Map<String, Submission> _submissions = {}; // studentId -> Submission
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Roster
      final students =
          await _classService.fetchStudentsInClass(widget.classroom.classId);

      // 2. Fetch Submissions
      final submissionList = await _submissionService
          .fetchSubmissionsForClasswork(widget.classwork.classworkId);
      final submissionMap = {for (var s in submissionList) s.studentId: s};

      if (mounted) {
        setState(() {
          _students = students;
          _submissions = submissionMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _saveGrade(String studentId, int grade) async {
    // If submission exists, update it. If not, create a shell submission?
    // Policy: Usually you can only grade AFTER submission.
    // However, teachers might want to grade offline work.
    // For now, let's assume we update the existing submission or create a new one if allowed.
    // If no submission exists, we create one with empty answer text but with a grade.

    try {
      final existing = _submissions[studentId];
      final submission = Submission(
        submissionId: existing?.submissionId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        classworkId: widget.classwork.classworkId,
        studentId: studentId,
        answerText: existing?.answerText ?? '[Graded by Teacher]',
        attachmentUrl: existing?.attachmentUrl,
        submittedAt: existing?.submittedAt ?? DateTime.now(),
        grade: grade,
      );

      await _submissionService.submitSubmission(submission);

      if (mounted) {
        setState(() {
          _submissions[studentId] = submission;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Grade saved'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving grade: $e')),
        );
      }
    }
  }

  void _showGradeDialog(User student) {
    final submission = _submissions[student.userId];
    final controller =
        TextEditingController(text: submission?.grade?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grade for ${student.fullname}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (submission != null) ...[
              const Text('Submission:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (submission.answerText.isNotEmpty)
                Text(submission.answerText,
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              if (submission.attachmentUrl != null)
                TextButton.icon(
                  onPressed: () {
                    // Open link
                  },
                  icon: const Icon(Icons.attachment),
                  label: const Text('View Attachment'),
                ),
              const SizedBox(height: 16),
            ] else
              const Text(
                  'No submission yet. You can still assign a grade for offline work.',
                  style: TextStyle(color: Colors.orange)),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Grade (out of ${widget.classwork.points})',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                if (val > widget.classwork.points) {
                  // Warning? Allow extra credit? Let's just warn but allow for now
                }
                _saveGrade(student.userId, val);
                Navigator.pop(context);
              }
            },
            child: const Text('Save Grade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.classwork.title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).cardTheme.color,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Students: ${_students.length}'),
                      Text('Max Points: ${widget.classwork.points}'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: _students.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final submission = _submissions[student.userId];
                      final hasSubmission = submission != null;
                      final isGraded = submission?.grade != null;

                      return ListTile(
                        onTap: () => _showGradeDialog(student),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(
                            student.fullname.isNotEmpty
                                ? student.fullname[0]
                                : '?',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(student.fullname,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          hasSubmission
                              ? 'Submitted: ${submission.submittedAt.toString().split(' ').first}'
                              : 'No submission',
                          style: TextStyle(
                            color: hasSubmission ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isGraded
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isGraded
                                    ? Colors.green
                                    : Colors.grey.withOpacity(0.3)),
                          ),
                          child: Text(
                            isGraded
                                ? '${submission?.grade} / ${widget.classwork.points}'
                                : '-- / ${widget.classwork.points}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isGraded
                                  ? Colors.green
                                  : Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
