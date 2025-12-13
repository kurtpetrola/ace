// lib/features/student_dashboard/presentation/submission_dialog.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/models/submission.dart';

class SubmissionDialog extends StatefulWidget {
  final Classwork classwork;
  final String studentId;

  const SubmissionDialog({
    super.key,
    required this.classwork,
    required this.studentId,
  });

  @override
  State<SubmissionDialog> createState() => _SubmissionDialogState();
}

class _SubmissionDialogState extends State<SubmissionDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _answerController = TextEditingController();

  bool _isSubmitting = false;

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate network delay for UX
    await Future.delayed(const Duration(milliseconds: 800));

    final submission = Submission(
      submissionId: DateTime.now().millisecondsSinceEpoch.toString(),
      classworkId: widget.classwork.classworkId,
      studentId: widget.studentId,
      answerText: _answerController.text.trim(),
      submittedAt: DateTime.now(),
      attachmentUrl: null,
      grade: _calculateGrade(),
    );

    if (mounted) {
      Navigator.of(context).pop(submission);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardTheme.color,
        surfaceTintColor: Theme.of(context).cardTheme.color,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorPalette.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Ionicons.cloud_upload_outline,
                        color: ColorPalette.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submit Work',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            'Type your answer below',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Answer Input
                TextFormField(
                  controller: _answerController,
                  maxLines: 8,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your answer here...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? Theme.of(context).colorScheme.surface
                        : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerTheme.color ??
                            Colors.grey.shade200,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerTheme.color ??
                            Colors.grey.shade200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorPalette.primary, width: 1.5),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter your answer'
                      : null,
                ),

                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).textTheme.bodyMedium?.color,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      child:
                          const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Ionicons.send),
                      label: Text(_isSubmitting ? 'Sending...' : 'Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  int? _calculateGrade() {
    final correctAnswer = widget.classwork.correctAnswer;
    if (correctAnswer == null || correctAnswer.trim().isEmpty) return null;

    final studentAnswer = _answerController.text.trim();
    if (studentAnswer.toLowerCase() == correctAnswer.trim().toLowerCase()) {
      return widget.classwork.points;
    }
    return null;
  }
}
