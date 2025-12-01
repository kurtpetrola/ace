// lib/features/student_dashboard/presentation/tabs/people_tab.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/user.dart';
import 'package:ace/services/class_service.dart';

// Convert PeopleTab to a StatefulWidget to manage the asynchronous data fetching
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
        print('Error fetching class roster: $e');
        setState(() {
          _errorMessage = 'Failed to load roster. Check connectivity.';
          _isLoading = false;
        });
      }
    }
  }

  // Helper widget to build each person tile
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Separate the hardcoded teachers from the dynamic students
    final teachers = [
      // 1. The main teacher/creator from the Classroom object
      _buildPersonTile(
          context, widget.classroom.creator, 'Teacher', Colors.red),
      // 2. Placeholder for a co-teacher (replace with dynamic loading if available)
      _buildPersonTile(
          context, 'Mr. Assistant Tutor', 'Co-Teacher', Colors.red),
    ];

    // Convert dynamic students into tiles
    final studentTiles = _students
        .map((student) =>
            _buildPersonTile(context, student.fullname, 'Student', Colors.blue))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Teachers Section ---
          Text(
            'Teachers',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(height: 10),
          ...teachers,

          const SizedBox(height: 30),

          // --- Classmates Section ---
          Text(
            'Classmates (${_students.length} Students)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(height: 10),
          // Dynamically loaded students
          if (studentTiles.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text('No students currently enrolled in this class.'),
            ),
          ...studentTiles,
        ],
      ),
    );
  }
}
