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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post cannot be empty.')),
        );
      }
      return;
    }

    if (mounted) setState(() => _isPosting = true);

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
        setState(() => _isPosting = false);
        if (success) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'New Class Post',
        style: TextStyle(color: ColorPalette.accentBlack),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 5,
        maxLength: 500,
        style: const TextStyle(color: ColorPalette.accentBlack),
        decoration: InputDecoration(
          hintText: 'Share an update, question, or comment...',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: ColorPalette.secondary, width: 2),
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
            foregroundColor: ColorPalette.accentBlack,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isPosting ? null : _submitPost,
          child: _isPosting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ColorPalette.accentBlack),
                  ),
                )
              : const Text(
                  'Post',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
