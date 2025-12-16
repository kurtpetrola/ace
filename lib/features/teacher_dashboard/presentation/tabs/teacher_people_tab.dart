// lib/features/teacher_dashboard/presentation/tabs/teacher_people_tab.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/user.dart';
import 'package:ace/services/class_service.dart';
import 'package:ionicons/ionicons.dart';

class TeacherPeopleTab extends StatefulWidget {
  final Classroom classroom;
  const TeacherPeopleTab({super.key, required this.classroom});

  @override
  State<TeacherPeopleTab> createState() => _TeacherPeopleTabState();
}

class _TeacherPeopleTabState extends State<TeacherPeopleTab> {
  final ClassService _classService = ClassService();
  List<User> _students = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRoster();
  }

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

  Future<void> _addStudent() async {
    final TextEditingController _idController = TextEditingController();
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Student'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Enter the Student ID to enroll them in this class.'),
                const SizedBox(height: 10),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'Student ID',
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final id = _idController.text.trim();
                  if (id.isEmpty) return;

                  // Check if already in list
                  if (_students.any((s) => s.userId == id)) {
                    setState(() {
                      errorText = 'Student already enrolled';
                    });
                    return;
                  }

                  // Check if exists in DB
                  final exists = await _classService.checkStudentExists(id);
                  if (!exists) {
                    setState(() {
                      errorText = 'Student ID not found';
                    });
                    return;
                  }

                  // Enroll
                  await _classService.enrollStudentInClass(
                      id, widget.classroom.classId);
                  Navigator.pop(context); // Close dialog
                  _fetchRoster(); // Refresh list
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Student $id added successfully')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context,
      {VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Divider(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3))),
          if (onAdd != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Ionicons.person_add,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: onAdd,
              tooltip: 'Add Student',
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStudentCard(User user) {
    final initials = user.fullname.isNotEmpty ? user.fullname[0] : '?';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ??
              Colors.grey.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Text(
            initials.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.fullname,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            // TODO: Implement remove student or email student
          },
          icon: Icon(Ionicons.mail_outline,
              color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Ionicons.alert_circle_outline,
                size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: _fetchRoster,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Students', context, onAdd: _addStudent),
          Text(
            '${_students.length} students',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (_students.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Theme.of(context).dividerTheme.color ??
                        Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Ionicons.people_outline,
                      size: 48, color: Theme.of(context).hintColor),
                  const SizedBox(height: 12),
                  Text(
                    'No students enrolled yet',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._students.map((student) => _buildStudentCard(student)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
