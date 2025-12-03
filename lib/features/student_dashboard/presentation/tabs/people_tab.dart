// lib/features/student_dashboard/presentation/tabs/people_tab.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/user.dart';
import 'package:ace/services/class_service.dart';

class PeopleTab extends StatefulWidget {
  final Classroom classroom;
  const PeopleTab({super.key, required this.classroom});

  @override
  State<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  final ClassService _classService = ClassService();
  List<User> _students = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRoster();
  }

  // Asynchronously fetches the student roster for the current class
  Future<void> _fetchRoster() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roster =
          await _classService.fetchStudentsInClass(widget.classroom.classId);
      if (mounted) {
        setState(() {
          _students = roster;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load roster. Check connectivity.';
          _isLoading = false;
        });
      }
    }
  }

// Helper widget to build each person tile
  Widget _buildPersonCard(String name, String role, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(role.contains('Teacher') ? Icons.school : Icons.person,
              color: color),
        ),
        title: Text(name),
        subtitle: Text(role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null)
      return Center(
          child:
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)));

    final teachers = [
      _buildPersonCard(widget.classroom.creator, 'Teacher', Colors.red),
      _buildPersonCard('Mr. Assistant Tutor', 'Co-Teacher', Colors.red),
    ];

    final studentCards = _students
        .map((s) => _buildPersonCard(s.fullname, 'Student', Colors.blue))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Teachers Section ---
          Text('Teachers', style: Theme.of(context).textTheme.headlineSmall),
          const Divider(),
          ...teachers,
          const SizedBox(height: 30),
          // --- Classmates Section ---
          Text('Classmates (${_students.length})',
              style: Theme.of(context).textTheme.headlineSmall),
          const Divider(),
          if (studentCards.isEmpty)
            Center(
                child: Text('No students enrolled.',
                    style: TextStyle(color: Colors.grey[600]))),
          ...studentCards,
        ],
      ),
    );
  }
}
