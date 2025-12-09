// lib/features/teacher_dashboard/presentation/dialogs/submissions_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:ace/models/submission.dart';
import 'package:ace/services/submission_service.dart';

class TeacherSubmissionsDetailDialog extends StatefulWidget {
  final String classworkId;
  final SubmissionService submissionService;

  const TeacherSubmissionsDetailDialog({
    super.key,
    required this.classworkId,
    required this.submissionService,
  });

  @override
  State<TeacherSubmissionsDetailDialog> createState() =>
      _TeacherSubmissionsDetailDialogState();
}

class _TeacherSubmissionsDetailDialogState
    extends State<TeacherSubmissionsDetailDialog> {
  List<Submission> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    setState(() => _isLoading = true);
    _submissions = await widget.submissionService.fetchSubmissionsForClasswork(
      widget.classworkId,
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).cardTheme.color,
      surfaceTintColor: Theme.of(context).cardTheme.color,
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Student Submissions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _submissions.isEmpty
                        ? const Center(
                            child: Text('No submissions yet'),
                          )
                        : ListView.separated(
                            itemCount: _submissions.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final s = _submissions[i];
                              return ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(s.studentId),
                                subtitle: Text(
                                    'Submitted at: ${s.submittedAt.toLocal().toString().split('.').first}'),
                                trailing: const Icon(Icons.check_circle,
                                    color: Colors.green),
                              );
                            },
                          ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close')),
                  ),
                ],
              ),
      ),
    );
  }
}
