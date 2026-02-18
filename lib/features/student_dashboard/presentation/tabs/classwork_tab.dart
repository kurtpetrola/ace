// lib/features/student_dashboard/presentation/tabs/classwork_tab.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/models/submission.dart';
import 'package:ace/services/classwork_service.dart';
import 'package:ace/services/submission_service.dart';
import 'package:ace/features/student_dashboard/presentation/submission_dialog.dart';

class ClassworkTab extends StatefulWidget {
  final Classroom classroom;
  final String studentId;

  const ClassworkTab({
    super.key,
    required this.classroom,
    required this.studentId,
  });

  @override
  State<ClassworkTab> createState() => _ClassworkTabState();
}

class _ClassworkTabState extends State<ClassworkTab> {
  final ClassworkService _classworkService = ClassworkService();
  final SubmissionService _submissionService = SubmissionService();

  List<Classwork> _classworkList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasswork();
  }

  Future<void> _fetchClasswork() async {
    setState(() => _isLoading = true);

    try {
      _classworkList = await _classworkService
          .fetchClassworkForClass(widget.classroom.classId);
    } catch (e) {
      debugPrint('Error fetching classwork: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// fetch full submission to check grades
  Future<Submission?> _getSubmission(Classwork c) async {
    return await _submissionService.getStudentSubmission(
      c.classworkId,
      widget.studentId,
    );
  }

  IconData _getIcon(ClassworkType type) {
    switch (type) {
      case ClassworkType.assignment:
        return Icons.assignment;
      case ClassworkType.quiz:
        return Icons.quiz_outlined;
      case ClassworkType.reading:
        return Ionicons.document_text_outline;
      case ClassworkType.project:
        return Icons.assignment_turned_in;
    }
  }

  Color _getColor(ClassworkType type) {
    switch (type) {
      case ClassworkType.assignment:
        return Colors.blue;
      case ClassworkType.quiz:
        return Colors.red;
      case ClassworkType.reading:
        return Colors.green;
      case ClassworkType.project:
        return Colors.purple;
    }
  }

  String _subtitle(Classwork c) {
    if (c.dueDate == null) {
      return 'Posted: ${_format(c.createdAt)}';
    }
    return c.isOverdue
        ? 'Overdue: ${c.formattedDueDate}'
        : 'Due: ${c.formattedDueDate}';
  }

  String _format(DateTime d) => '${d.month}/${d.day}/${d.year}';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_classworkList.isEmpty) {
      return _emptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchClasswork,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _classworkList.length,
        itemBuilder: (_, i) => _classworkCard(_classworkList[i]),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Ionicons.folder_open_outline,
                size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            'No classwork posted yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _classworkCard(Classwork c) {
    final color = _getColor(c.type);

    return FutureBuilder<Submission?>(
      future: _getSubmission(c),
      builder: (_, snapshot) {
        final submission = snapshot.data;
        final isSubmitted = submission != null;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: color),
                  Expanded(
                    child: InkWell(
                      onTap: () => _openDetails(c),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_getIcon(c.type),
                                      color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.type.displayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSubmitted) ...[
                                  if (c.type == ClassworkType.quiz) ...[
                                    if (submission.grade == null)
                                      _buildStatusBadge('Pending',
                                          Colors.orange, Icons.access_time),
                                    if (submission.grade != null &&
                                        submission.grade == c.points)
                                      _buildStatusBadge('Correct', Colors.green,
                                          Ionicons.checkmark_circle),
                                    if (submission.grade != null &&
                                        submission.grade != c.points)
                                      _buildStatusBadge(
                                          'Incorrect', Colors.red, Icons.close),
                                  ] else
                                    _buildStatusBadge('Done', Colors.green,
                                        Ionicons.checkmark_circle),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _subtitle(c),
                              style: TextStyle(
                                fontSize: 13,
                                color: c.isOverdue
                                    ? Colors.red
                                    : Colors.grey.shade600,
                                fontWeight: c.isOverdue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${c.points} Points',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade500)),
                                Text('Tap to view details',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade400)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(Classwork c) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardTheme.color,
        surfaceTintColor: Theme.of(context).cardTheme.color,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Text(
                    c.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<Submission?>(
                future: _getSubmission(c),
                builder: (_, snap) {
                  final submission = snap.data;
                  final submitted = submission != null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Show Correct Answer if Graded
                      if (submitted &&
                          submission.grade != null &&
                          c.correctAnswer != null &&
                          c.correctAnswer!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Correct Answer',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.correctAnswer!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: Builder(
                          builder: (innerContext) {
                            // Logic for button state
                            final isOverdue = c.isOverdue;
                            final canResubmit = c.allowResubmission;

                            // 1. If Overdue -> Disable (Always Strict)
                            if (isOverdue) {
                              return ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Ionicons.time_outline),
                                label: const Text('Past Due Date'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.grey,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }

                            // 2. If Submitted
                            if (submitted) {
                              if (!canResubmit) {
                                return ElevatedButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Ionicons.lock_closed),
                                  label: const Text('Resubmission Disabled'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade300,
                                    foregroundColor: Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              }

                              // Allow Resubmission
                              return ElevatedButton.icon(
                                onPressed: () async {
                                  // Use innerContext to pop the dialog
                                  Navigator.pop(innerContext);

                                  // Use the outer `context` (from State) for the new dialog
                                  if (!mounted) return;
                                  final newSubmission =
                                      await showDialog<Submission>(
                                    context: context,
                                    builder: (_) => SubmissionDialog(
                                      classwork: c,
                                      studentId: widget.studentId,
                                    ),
                                  );

                                  if (newSubmission != null) {
                                    await _submissionService
                                        .submitSubmission(newSubmission);
                                    await _fetchClasswork();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Resubmission successful'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Ionicons.refresh),
                                label: const Text('Resubmit Work'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getColor(c.type),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }

                            // 3. Not Submitted, Not Overdue -> Allow Submit
                            return ElevatedButton.icon(
                              onPressed: () async {
                                // Pop details dialog using its context
                                Navigator.pop(innerContext);

                                if (!mounted) return;
                                // Show submission dialog using parent context
                                final submission = await showDialog<Submission>(
                                  context: context,
                                  builder: (_) => SubmissionDialog(
                                    classwork: c,
                                    studentId: widget.studentId,
                                  ),
                                );

                                if (submission != null) {
                                  await _submissionService
                                      .submitSubmission(submission);
                                  await _fetchClasswork();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Submission successful'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Ionicons.cloud_upload),
                              label: const Text('Submit Work'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getColor(c.type),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
