// lib/features/student_dashboard/presentation/tabs/stream_tab.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';

// Placeholder for the "Stream" tab content
class StreamTab extends StatelessWidget {
  final Classroom classroom;

  const StreamTab({super.key, required this.classroom});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          // Placeholder for posting new announcements/messages
          Card(
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('Share something with your class...'),
              onTap: () {
                // TODO: Implement dialog for creating a post
              },
            ),
          ),
          const SizedBox(height: 20),
          // Placeholder for recent announcements/posts
          _buildPostCard(
            context,
            '${classroom.creator} posted a new announcement.',
            'Hello everyone! Welcome to the new semester of ${classroom.className}. Please check the Classwork tab for the first assignment, due next week.',
            '${classroom.creator} • Just now',
          ),
          _buildPostCard(
            context,
            'Upcoming test reminder',
            'Remember, the mid-term exam is scheduled for November 15th. Start reviewing your notes!',
            'System Notification • 2 days ago',
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
      BuildContext context, String title, String content, String footer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Text(content),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                footer,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
