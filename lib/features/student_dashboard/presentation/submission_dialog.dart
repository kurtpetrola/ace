// lib/features/student_dashboard/presentation/submission_dialog.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/models/submission.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';

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

  // File upload placeholders (disabled for now)
  String? _attachmentUrl;
  bool _isSubmitting = false;

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final submission = Submission(
      submissionId: DateTime.now().millisecondsSinceEpoch.toString(),
      classworkId: widget.classwork.classworkId,
      studentId: widget.studentId,
      answerText: _answerController.text.trim(),
      submittedAt: DateTime.now(),
      attachmentUrl: _attachmentUrl, // future use
    );

    Navigator.of(context).pop(submission);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Submit Work',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),

              /// Answer input
              TextFormField(
                controller: _answerController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Your Answer',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Answer cannot be empty'
                    : null,
              ),

              /// File upload intentionally disabled
              /*
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach File (Coming Soon)'),
              ),
              */

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
