// lib/features/admin_dashboard/presentation/admin_class_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/services/class_service.dart';
import 'package:ace/features/admin_dashboard/presentation/class_creation_dialog.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_class_roster_dialog.dart';

class AdminClassManagementScreen extends StatefulWidget {
  const AdminClassManagementScreen({super.key});

  @override
  State<AdminClassManagementScreen> createState() =>
      _AdminClassManagementScreenState();
}

class _AdminClassManagementScreenState
    extends State<AdminClassManagementScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final ClassService _classService = ClassService();

  String? _currentStudentId;
  List<Classroom> _enrolledClasses = [];
  List<Classroom> _availableClasses = [];
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _fetchAvailableClasses();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  // Fetches all classes that the admin can enroll students into
  Future<void> _fetchAvailableClasses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _availableClasses = await _classService.fetchAllAvailableClasses();
      _statusMessage = null; // Clear old status if successful
    } catch (e) {
      print('Error fetching available classes: $e');
      _statusMessage = 'Failed to load available classes.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Searches for a student and fetches their enrolled classes
  Future<void> _searchAndFetchClasses() async {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      setState(() {
        _currentStudentId = null;
        _enrolledClasses = [];
        _statusMessage = 'Please enter a Student ID.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Searching for student...';
    });

    try {
      final exists = await _classService.checkStudentExists(studentId);

      if (!exists) {
        setState(() {
          _statusMessage = 'Error: Student ID "$studentId" not found.';
          _currentStudentId = null;
          _enrolledClasses = [];
        });
        return;
      }

      // Student found, fetch their current classes
      _enrolledClasses = await _classService.fetchStudentClasses(studentId);

      setState(() {
        _currentStudentId = studentId;
        _statusMessage =
            'Student ID: $studentId found. Enrolled in ${_enrolledClasses.length} classes.';
      });
    } catch (e) {
      print('Error during student search/fetch: $e');
      setState(() {
        _statusMessage = 'An error occurred during search.';
        _currentStudentId = null;
        _enrolledClasses = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Enrolls the current student in a chosen class
  Future<void> _enrollStudent(String classId, String className) async {
    if (_currentStudentId == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Enrolling $_currentStudentId in $className...';
    });

    try {
      // NOTE: This now updates both the Student and Class nodes in Firebase
      await _classService.enrollStudentInClass(_currentStudentId!, classId);

      // Refresh the enrolled list immediately
      _enrolledClasses =
          await _classService.fetchStudentClasses(_currentStudentId!);

      setState(() {
        _statusMessage =
            'Successfully enrolled $_currentStudentId in $className!';
        // Use setState to trigger rebuild with the new list
      });
    } catch (e) {
      print('Enrollment error: $e');
      setState(() {
        _statusMessage = 'Failed to enroll student: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handles unenrollment and status updates
  Future<void> _unenrollStudent(String classId, String className) async {
    if (_currentStudentId == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Unenrolling $_currentStudentId from $className...';
    });

    try {
      await _classService.unenrollStudentFromClass(_currentStudentId!, classId);
      await _searchAndFetchClasses(); // Refresh list and status
      setState(() {
        _statusMessage =
            'Successfully unenrolled $_currentStudentId from $className.';
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

  // Handles the class creation flow
  void _showCreateClassDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassCreationDialog(
          onClassCreated: (newClass) async {
            setState(() {
              _isLoading = true;
              _statusMessage = 'Creating new class "${newClass.className}"...';
            });
            try {
              // Call the new service method to save the class to Firebase
              await _classService.createNewClass(newClass);
              // Refresh the list of available classes displayed on this screen
              await _fetchAvailableClasses();
              setState(() {
                _statusMessage =
                    'Class "${newClass.className}" created successfully!';
              });
            } catch (e) {
              print('Class creation error: $e');
              setState(() {
                _statusMessage = 'Error creating class: $e';
              });
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
        );
      },
    );
  }

  // NEW: Shows the class-specific roster management dialog
  void _showRosterDialog(Classroom classToManage) {
    showDialog(
      context: context,
      builder: (context) {
        return AdminClassRosterDialog(
          classroom: classToManage,
          // Optional: Refresh the 'Available Classes' list if the roster update affects local display logic
          onRosterUpdated: _fetchAvailableClasses,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Create New Class Button (Updated to call the dialog)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showCreateClassDialog, // *** HOOKED UP ***
            icon: const Icon(Ionicons.add_circle, color: Colors.white),
            label: const Text('Create New Class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.secondary,
              foregroundColor: ColorPalette.accentBlack,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),

        // 2. Student Search and Status
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              TextField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  labelText: 'Search Student ID (e.g., STU-001)',
                  suffixIcon: IconButton(
                    icon: const Icon(Ionicons.search),
                    onPressed: _searchAndFetchClasses,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _searchAndFetchClasses(),
              ),
              const SizedBox(height: 10),
              if (_statusMessage != null)
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith('Error')
                        ? Colors.red
                        : ColorPalette.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const Divider(),
            ],
          ),
        ),

        // 3. Main Content: Enrolled Classes vs. Available Classes
        if (_isLoading) const LinearProgressIndicator(),

        if (_currentStudentId != null)
          Expanded(
            child: Row(
              children: [
                // Left: Currently Enrolled Classes (Student-centric view)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enrolled Classes',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: ColorPalette.secondary)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _enrolledClasses.isEmpty
                              ? const Center(
                                  child: Text('Not enrolled in any classes.'))
                              : ListView.builder(
                                  itemCount: _enrolledClasses.length,
                                  itemBuilder: (context, index) {
                                    final cls = _enrolledClasses[index];
                                    return Card(
                                      child: ListTile(
                                        title: Text(cls.className),
                                        subtitle: Text(cls.classId),
                                        trailing: IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red),
                                          onPressed: () => _unenrollStudent(
                                              cls.classId, cls.className),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right: Available Classes (Global list, now with Roster link)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Classes', // Renamed label
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: ColorPalette.secondary)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _availableClasses.length,
                            itemBuilder: (context, index) {
                              final cls = _availableClasses[index];
                              // Check if the searched student is already enrolled (for the original function)
                              final isEnrolled = _enrolledClasses
                                  .any((e) => e.classId == cls.classId);

                              return Card(
                                color: isEnrolled
                                    ? Colors.grey[200]
                                    : Colors.white,
                                child: ListTile(
                                  title: Text(cls.className),
                                  subtitle: Text(cls.classId),
                                  trailing: Row(
                                    // Use Row for multiple actions
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 1. Enrollment action (only visible if a student is searched)
                                      if (_currentStudentId != null)
                                        IconButton(
                                          icon: Icon(
                                            isEnrolled
                                                ? Icons.check
                                                : Ionicons.add_circle,
                                            color: isEnrolled
                                                ? Colors.green
                                                : ColorPalette.secondary,
                                          ),
                                          onPressed: isEnrolled
                                              ? null // Cannot enroll twice
                                              : () => _enrollStudent(
                                                  cls.classId, cls.className),
                                          tooltip: isEnrolled
                                              ? 'Enrolled'
                                              : 'Enroll Student',
                                        ),

                                      // 2. Class Roster Management (new feature)
                                      IconButton(
                                        icon: const Icon(Ionicons.people,
                                            color: ColorPalette.accentBlack),
                                        tooltip: 'Manage Class Roster',
                                        onPressed: () => _showRosterDialog(cls),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          // Default instruction message
          Expanded(
            child: Center(
              child: Text(
                'Enter a student ID above to manage their class enrollment, or click "Manage Roster" next to any class.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
