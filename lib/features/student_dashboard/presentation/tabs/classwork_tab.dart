// lib/features/student_dashboard/presentation/tabs/classwork_tab.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/models/classroom.dart';

// Placeholder for the "Classwork" tab content
class ClassworkTab extends StatelessWidget {
  final Classroom classroom;

  const ClassworkTab({super.key, required this.classroom});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assignments for ${classroom.className}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(height: 30),
          _buildClassworkItem(
            context,
            Icons.assignment,
            'Assignment 1: Introduction Essay',
            'Due: Sep 15, 11:59 PM',
            Colors.blue,
          ),
          _buildClassworkItem(
            context,
            Ionicons.document_text_outline,
            'Reading Material: Chapter 1 - Overview',
            'Posted: Sep 1, 2024',
            Colors.green,
          ),
          _buildClassworkItem(
            context,
            Icons.quiz_outlined,
            'Mid-Term Exam (Quiz)',
            'Due: Nov 15, 1:00 PM',
            Colors.red,
          ),
          _buildClassworkItem(
            context,
            Icons.assignment_turned_in,
            'Project Proposal',
            'Submitted: Oct 5, 2024 (Grade: 95/100)',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildClassworkItem(BuildContext context, IconData icon, String title,
      String subtitle, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to assignment detail page
        },
      ),
    );
  }
}
