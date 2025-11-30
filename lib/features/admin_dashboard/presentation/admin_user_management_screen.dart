// lib/features/admin_dashboard/presentation/admin_user_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/models/user.dart';
import 'package:ace/services/user_service.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final UserService _userService = UserService();
  Future<List<User>>? _studentsFuture;
  Set<String> _selectedSegment = {'students'};

  @override
  void initState() {
    super.initState();
    _fetchUserList();
  }

  void _fetchUserList() {
    if (_selectedSegment.contains('students')) {
      setState(() {
        _studentsFuture = _userService.fetchAllStudents();
      });
    } else {
      setState(() {
        _studentsFuture = Future.value([]);
      });
    }
  }

  // Function to show the Firebase Console instruction message
  void _showConsoleMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'User editing and password reset are managed via the Firebase Console.'),
        backgroundColor: ColorPalette.secondary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab or segment control for different user groups
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'students', label: Text('Students')),
              ButtonSegment(value: 'admins', label: Text('Admins (TODO)')),
            ],
            selected: _selectedSegment,
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedSegment = newSelection;
                _fetchUserList();
              });
            },
            selectedIcon: const Icon(Ionicons.checkmark_circle),
          ),
        ),
        // List of all students
        Expanded(
          child: FutureBuilder<List<User>>(
            future: _studentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading users: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final studentList = snapshot.data ?? [];

              if (studentList.isEmpty) {
                return Center(
                  child: Text(
                    _selectedSegment.contains('students')
                        ? 'No student accounts found in the database.'
                        : 'No admin accounts found in the database.',
                    style: TextStyle(
                        color: ColorPalette.secondary.withOpacity(0.8),
                        fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                itemCount: studentList.length,
                itemBuilder: (context, index) {
                  final student = studentList[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            ColorPalette.secondary.withOpacity(0.1),
                        child: const Icon(Icons.person,
                            color: ColorPalette.secondary),
                      ),
                      title: Text(student.fullname,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${student.userId}',
                              style: const TextStyle(fontSize: 12)),
                          Text('Email: ${student.email}',
                              style: const TextStyle(fontSize: 12)),
                          Text('Dept: ${student.department}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Ionicons.information_circle_outline,
                            color: Colors.grey),
                        onPressed: () => _showConsoleMessage(
                            context), // Instructs admin to use console
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
