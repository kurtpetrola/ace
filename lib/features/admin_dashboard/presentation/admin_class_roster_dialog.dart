// lib/features/admin_dashboard/presentation/admin_class_roster_dialog.dart

import 'package:ace/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/user.dart';
import 'package:ace/services/class_service.dart';

class AdminClassRosterDialog extends StatefulWidget {
  final Classroom classroom;
  final VoidCallback onRosterUpdated;

  const AdminClassRosterDialog({
    super.key,
    required this.classroom,
    required this.onRosterUpdated,
  });

  @override
  State<AdminClassRosterDialog> createState() => _AdminClassRosterDialogState();
}

class _AdminClassRosterDialogState extends State<AdminClassRosterDialog> {
  final ClassService _classService = ClassService();
  final TextEditingController _studentIdController = TextEditingController();
  List<User> _rosterStudents = [];
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _fetchRoster();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  // Fetches the full list of student User objects for this class
  Future<void> _fetchRoster() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading class roster...';
    });

    try {
      _rosterStudents =
          await _classService.fetchStudentsInClass(widget.classroom.classId);
      _statusMessage =
          'Roster loaded. Total students: ${_rosterStudents.length}';
    } catch (e) {
      print('Error fetching class roster: $e');
      _statusMessage = 'Error loading roster: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handles adding a student via the text field
  Future<void> _addStudentBySearch() async {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      setState(() => _statusMessage = 'Please enter a Student ID.');
      return;
    }

    if (_rosterStudents.any((s) => s.userId == studentId)) {
      setState(() => _statusMessage = 'Error: Student is already enrolled.');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking student ID $studentId...';
    });

    try {
      // 1. Check if student exists
      final exists = await _classService.checkStudentExists(studentId);
      if (!exists) {
        setState(
            () => _statusMessage = 'Error: Student ID "$studentId" not found.');
        return;
      }

      // 2. Enroll the student
      setState(() => _statusMessage = 'Enrolling student $studentId...');
      await _classService.enrollStudentInClass(
          studentId, widget.classroom.classId);

      // 3. Refresh the UI
      _studentIdController.clear();
      await _fetchRoster(); // Reload the list
      widget.onRosterUpdated(); // Notify parent screen
      setState(() {
        _statusMessage = 'Successfully enrolled $studentId!';
      });
    } catch (e) {
      print('Enrollment error: $e');
      setState(() => _statusMessage = 'Failed to enroll student: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Handles unenrollment from the list tile
  Future<void> _unenrollStudent(String studentId, String fullname) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Unenrolling $fullname from class...';
    });

    try {
      await _classService.unenrollStudentFromClass(
          studentId, widget.classroom.classId);

      // Refresh the UI
      await _fetchRoster(); // Reload the list
      widget.onRosterUpdated(); // Notify parent screen
      setState(() {
        _statusMessage = 'Successfully unenrolled $fullname.';
      });
    } catch (e) {
      print('Unenrollment error: $e');
      setState(() {
        _statusMessage = 'Failed to unenroll student: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPersonTile(User student) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: ColorPalette.accentBlack.withOpacity(0.1),
        child: const Icon(Icons.person, color: ColorPalette.accentBlack),
      ),
      title: Text(student.fullname),
      subtitle: Text('ID: ${student.userId} | Age: ${student.age}'),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle, color: Colors.red),
        onPressed: () => _unenrollStudent(student.userId, student.fullname),
        tooltip: 'Remove from class',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage Roster: ${widget.classroom.className}'),
      content: SizedBox(
        width: 400, // Fixed width for better dialog appearance
        height: 600, // Fixed height
        child: Column(
          children: [
            // Teacher Info
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.school, color: Colors.red),
              ),
              title: Text(widget.classroom.creator),
              subtitle: const Text('Teacher/Creator'),
            ),
            const Divider(),

            // Status Message and Loading
            if (_isLoading) const LinearProgressIndicator(),
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_statusMessage!,
                    style: TextStyle(
                        color: _statusMessage!.startsWith('Error')
                            ? Colors.red
                            : ColorPalette.secondary,
                        fontStyle: FontStyle.italic)),
              ),

            // Add Student Search
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  labelText: 'Enter Student ID to Add',
                  suffixIcon: IconButton(
                    icon: const Icon(Ionicons.add_circle),
                    onPressed: _addStudentBySearch,
                  ),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addStudentBySearch(),
              ),
            ),

            // Student Roster List
            Expanded(
              child: ListView(
                children: _rosterStudents.map(_buildPersonTile).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
