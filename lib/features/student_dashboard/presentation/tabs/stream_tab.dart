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
  // Get the Hive box reference for login data
  final Box _loginbox = Hive.box("_loginbox");

  StreamTab({super.key, required this.classroom});

  // Function to format the timestamp into a human-readable string
  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  // Function to show the create post dialog and handle post creation
  void _showCreatePostDialog(BuildContext context) {
    final String currentUserId =
        _loginbox.get('User', defaultValue: 'Unknown-ID');
    final String currentUserName =
        _loginbox.get('UserName', defaultValue: 'Unknown User');

    if (currentUserId == 'Unknown-ID' || currentUserName == 'Unknown User') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: User session data is missing. Please re-login.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        onCreatePost: (content) => _streamService.createPost(
          classroom.classId,
          currentUserId,
          currentUserName,
          content,
        ),
      ),
    );
  }

// Widget to display a single stream post card
  Widget _buildPostCard(BuildContext context, Post post) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: ColorPalette.accentBlack.withOpacity(0.15),
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : '?',
                    style: const TextStyle(
                      color: ColorPalette.accentBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.accentBlack)),
                    Text(
                      _formatTimestamp(post.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
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
          return Center(child: Text('Error loading stream: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome to ${classroom.className} Stream!',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text('Class ID: ${classroom.classId}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Divider(height: 30),

                    // Create Post Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              ColorPalette.accentBlack.withOpacity(0.15),
                          child: const Icon(Icons.edit_note,
                              color: ColorPalette.accentBlack),
                        ),
                        title: const Text('Share something with your class...'),
                        onTap: () => _showCreatePostDialog(context),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Recent Posts (${posts.length})',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(),
                  ],
                ),
              ),
            ),
            // Real-time List of Posts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPostCard(context, posts[index]),
                childCount: posts.length,
              ),
            ),
            if (posts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text('No posts in the stream yet.',
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
