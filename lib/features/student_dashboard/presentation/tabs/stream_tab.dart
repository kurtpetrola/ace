// lib/features/student_dashboard/presentation/tabs/stream_tab.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/post.dart';
import 'package:ace/services/stream_service.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/student_dashboard/presentation/widgets/create_post_dialog.dart';
import 'package:hive/hive.dart';

class StreamTab extends StatelessWidget {
  final Classroom classroom;
  // Initialize the new stream service
  final StreamService _streamService = StreamService();
  // Get the Hive box reference (assuming it's already open)
  final Box _loginbox = Hive.box("_loginbox");

  StreamTab({super.key, required this.classroom});

  // Function to format the timestamp into a human-readable string
  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Function to show the create post dialog
  void _showCreatePostDialog(BuildContext context) {
    // ⚠️ CRITICAL: Retrieve the authenticated user's ID and Name from Hive
    // 'User' holds the studentId/adminId, and 'UserName' holds the fullname.
    final String currentUserId =
        _loginbox.get('User', defaultValue: 'Unknown-ID');
    final String currentUserName =
        _loginbox.get('UserName', defaultValue: 'Unknown User');

    // Basic check for valid data before creating a post
    if (currentUserId == 'Unknown-ID' || currentUserName == 'Unknown User') {
      // If session data is missing, notify the user.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: User session data is missing. Please re-login.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return CreatePostDialog(
          onCreatePost: (content) => _streamService.createPost(
            classroom.classId,
            currentUserId, // Use the real user ID
            currentUserName, // Use the real user Name
            content,
          ),
        );
      },
    );
  }

  // Widget to display a single stream post
  Widget _buildPostCard(
      BuildContext context, String authorName, String content, String footer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: ColorPalette.secondary.withOpacity(0.1),
                  child: Text(
                    authorName.isNotEmpty ? authorName[0] : '?',
                    style: const TextStyle(
                        color: ColorPalette.secondary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(authorName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            Text(content, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                footer,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens for real-time changes to the posts in Firebase
    return StreamBuilder<List<Post>>(
      stream: _streamService.getPostsStream(classroom.classId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading stream: ${snapshot.error.toString()}'),
          );
        }

        final posts = snapshot.data ?? [];

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to ${classroom.className} Stream!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Class ID: ${classroom.classId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(height: 30),

                    // Post Creation Card
                    Card(
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              ColorPalette.secondary.withOpacity(0.1),
                          child: const Icon(Icons.edit_note,
                              color: ColorPalette.secondary),
                        ),
                        title: const Text('Share something with your class...'),
                        onTap: () => _showCreatePostDialog(context),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Recent Posts (${posts.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
            // Real-time List of Posts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  // Display dynamic posts from Firebase, newest first
                  return _buildPostCard(
                    context,
                    post.authorName,
                    post.content,
                    '${post.authorName} • ${_formatTimestamp(post.timestamp)}',
                  );
                },
                childCount: posts.length,
              ),
            ),
            // Show a message if there are no posts
            if (posts.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      'No posts in the stream yet.',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
