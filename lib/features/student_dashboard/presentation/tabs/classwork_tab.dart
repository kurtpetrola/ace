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

  /// ✅ NEW — clean, fast submission check
  Future<bool> _hasSubmitted(Classwork c) async {
    final submission = await _submissionService.getStudentSubmission(
      c.classworkId,
      widget.studentId,
    );
    return submission != null;
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
        padding: const EdgeInsets.all(16),
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
          Icon(Ionicons.folder_open_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No classwork posted yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _classworkCard(Classwork c) {
    final color = _getColor(c.type);

    return FutureBuilder<bool>(
      future: _hasSubmitted(c),
      builder: (_, snapshot) {
        final submitted = snapshot.data ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(.1),
              child: Icon(_getIcon(c.type), color: color),
            ),
            title: Text(
              c.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _subtitle(c),
                  style: TextStyle(
                    color: c.isOverdue ? Colors.red : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _tag(c.type.displayName, color),
                    const SizedBox(width: 8),
                    Text('${c.points} pts',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const Spacer(),
                    if (submitted)
                      const Chip(
                        label: Text('Submitted'),
                        backgroundColor: Color(0x1A4CAF50),
                        labelStyle: TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openDetails(c),
          ),
        );
      },
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _openDetails(Classwork c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c.title),
        content: Text(c.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FutureBuilder<bool>(
            future: _hasSubmitted(c),
            builder: (_, snap) {
              final submitted = snap.data ?? false;

              return ElevatedButton(
                onPressed: submitted
                    ? null
                    : () async {
                        Navigator.pop(context);

                        final submission = await showDialog<Submission>(
                          context: context,
                          builder: (_) => SubmissionDialog(
                            classwork: c,
                            studentId: widget.studentId,
                          ),
                        );

                        if (submission != null) {
                          await _submissionService.submitSubmission(submission);

                          await _fetchClasswork();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Submission successful'),
                              ),
                            );
                          }
                        }
                      },
                child: Text(submitted ? 'Submitted' : 'Submit Work'),
              );
            },
          ),
        ],
      ),
    );
  }
}
