// lib/features/student_dashboard/presentation/tabs/people_tab.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';

// Placeholder for the "People" tab content
class PeopleTab extends StatelessWidget {
  final Classroom classroom;

  const PeopleTab({super.key, required this.classroom});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teachers',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(height: 10),
          _buildPersonTile(context, classroom.creator, 'Teacher', Colors.red),
          _buildPersonTile(
              context, 'Mr. Assistant Tutor', 'Co-Teacher', Colors.red),
          const SizedBox(height: 30),
          Text(
            'Classmates (42 Students)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(height: 10),
          _buildPersonTile(context, 'Alice Johnson', 'Student', Colors.blue),
          _buildPersonTile(context, 'Bob Williams', 'Student', Colors.blue),
          _buildPersonTile(context, 'Charlie Brown', 'Student', Colors.blue),
          _buildPersonTile(context, 'Dana Scully', 'Student', Colors.blue),
          // ... more students (in a real app, this would be loaded from DB)
        ],
      ),
    );
  }

  Widget _buildPersonTile(
      BuildContext context, String name, String role, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          role == 'Teacher' || role == 'Co-Teacher'
              ? Icons.school
              : Icons.person,
          color: color,
        ),
      ),
      title: Text(name),
      subtitle: Text(role),
      onTap: () {
        // TODO: Implement viewing a user profile
      },
    );
  }
}
