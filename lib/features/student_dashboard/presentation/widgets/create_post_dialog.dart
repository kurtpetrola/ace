// lib/features/student_dashboard/presentation/widgets/create_post_dialog.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';

class CreatePostDialog extends StatefulWidget {
  final Future<void> Function(String content) onCreatePost;

  const CreatePostDialog({super.key, required this.onCreatePost});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;

  void _submitPost() async {
    if (_controller.text.trim().isEmpty) {
      // Simple validation using ScaffoldMessenger
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post cannot be empty.')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isPosting = true;
      });
    }

    bool success = false;
    try {
      await widget.onCreatePost(_controller.text.trim());
      success = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
        if (success) {
          Navigator.of(context).pop(); // Close dialog on success
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Class Post'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 5,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: 'Share an update, question, or comment...',
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.secondary),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isPosting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.secondary,
            foregroundColor: Colors.white,
          ),
          onPressed: _isPosting ? null : _submitPost,
          child: _isPosting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Post'),
        ),
      ],
    );
  }
}
