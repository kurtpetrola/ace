// lib/features/admin_dashboard/presentation/admin_class_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/services/class_service.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_class_roster_dialog.dart';
import 'package:ace/features/admin_dashboard/presentation/class_creation_dialog.dart';

class AdminClassManagementScreen extends StatefulWidget {
  const AdminClassManagementScreen({super.key});

  @override
  State<AdminClassManagementScreen> createState() =>
      _AdminClassManagementScreenState();
}

class _AdminClassManagementScreenState
    extends State<AdminClassManagementScreen> {
  final ClassService _classService = ClassService();
  final TextEditingController _studentIdCtrl = TextEditingController();

  String? _currentStudentId;
  List<Classroom> _studentClasses = [];
  String? _status;

  // ---------------- STUDENT SEARCH ----------------
  Future<void> _searchStudent() async {
    final id = _studentIdCtrl.text.trim();
    if (id.isEmpty) return;

    final exists = await _classService.checkStudentExists(id);
    if (!exists) {
      setState(() {
        _currentStudentId = null;
        _studentClasses = [];
        _status = 'Student not found';
      });
      return;
    }

    final classes = await _classService.fetchStudentClasses(id);
    setState(() {
      _currentStudentId = id;
      _studentClasses = classes;
      _status = 'Managing classes for $id';
    });
  }

  // ---------------- ENROLLMENT ----------------
  Future<void> _enroll(Classroom cls) async {
    if (_currentStudentId == null) return;
    await _classService.enrollStudentInClass(
      _currentStudentId!,
      cls.classId,
    );
    _studentClasses =
        await _classService.fetchStudentClasses(_currentStudentId!);
    setState(() {});
  }

  Future<void> _unenroll(Classroom cls) async {
    if (_currentStudentId == null) return;
    await _classService.unenrollStudentFromClass(
      _currentStudentId!,
      cls.classId,
    );
    _studentClasses =
        await _classService.fetchStudentClasses(_currentStudentId!);
    setState(() {});
  }

  // ---------------- DIALOGS ----------------
  void _showCreateClassDialog() {
    showDialog(
      context: context,
      builder: (_) => ClassCreationDialog(
        onClassCreated: _classService.createNewClass,
      ),
    );
  }

  void _openRoster(Classroom cls) {
    showDialog(
      context: context,
      builder: (_) => AdminClassRosterDialog(
        classroom: cls,
        onRosterUpdated: () {},
      ),
    );
  }

  Future<void> _deleteClass(Classroom cls) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class?'),
        content: Text(
          'Are you sure you want to delete "${cls.className}"?\n\n'
          '⚠️ This will UNENROLL all students and DELETE all classwork/assignments associated with this class. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _classService.deleteClass(cls.classId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${cls.className}')),
        );
      }
    }
  }

  void _showEnrollmentDialog() {
    if (_currentStudentId == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: double.infinity,
          height: 400,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _StudentEnrollmentPanel(
              studentId: _currentStudentId,
              enrolled: _studentClasses,
              onEnroll: _enroll,
              onUnenroll: _unenroll,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        _Header(onCreate: _showCreateClassDialog),
        _StudentSearchBar(
          controller: _studentIdCtrl,
          onSearch: _searchStudent,
          status: _status,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ LEFT — CLASSES
                      Expanded(
                        flex: 3,
                        child: _Panel(
                          title: 'All Classes',
                          child: _AdminClassOverview(
                            stream: _classService.streamAllClasses(),
                            onRoster: _openRoster,
                            onDelete: _deleteClass,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ✅ RIGHT — ENROLLMENT (Always visible)
                      Expanded(
                        flex: 2,
                        child: _Panel(
                          title: 'Student Enrollment',
                          child: _StudentEnrollmentPanel(
                            studentId: _currentStudentId,
                            enrolled: _studentClasses,
                            onEnroll: _enroll,
                            onUnenroll: _unenroll,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Classes Panel
                      Expanded(
                        child: _Panel(
                          title: 'All Classes',
                          child: _AdminClassOverview(
                            stream: _classService.streamAllClasses(),
                            onRoster: _openRoster,
                            onDelete: _deleteClass,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_currentStudentId != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.school),
                          label: const Text('Manage Enrollment'),
                          onPressed: _showEnrollmentDialog,
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ---------------- SHARED PANEL ----------------
class _Panel extends StatelessWidget {
  final String title;
  final Widget child;

  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ---------------- HEADER ----------------
class _Header extends StatelessWidget {
  final VoidCallback onCreate;
  const _Header({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton.icon(
        icon: const Icon(Ionicons.add_circle),
        label: const Text('Create New Class'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 48),
        ),
        onPressed: onCreate,
      ),
    );
  }
}

// ---------------- STUDENT SEARCH ----------------
class _StudentSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final String? status;

  const _StudentSearchBar({
    required this.controller,
    required this.onSearch,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final hasStatus = status != null;
    final isError = hasStatus && status!.toLowerCase().contains('not found');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Search Student ID',
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: onSearch,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: ColorPalette.primary, width: 2),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
          if (hasStatus) ...[
            const SizedBox(height: 6),
            Text(
              status!,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: isError ? Colors.red : Colors.green.shade700,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------- ADMIN VIEW ----------------
class _AdminClassOverview extends StatelessWidget {
  final Stream<List<Classroom>> stream;
  final void Function(Classroom) onRoster;
  final void Function(Classroom) onDelete;

  const _AdminClassOverview({
    required this.stream,
    required this.onRoster,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Classroom>>(
      stream: stream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = snapshot.data!;
        if (classes.isEmpty) {
          return const Center(child: Text('No classes found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: classes.length,
          itemBuilder: (_, i) {
            final cls = classes[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(cls.className),
                subtitle: Text(cls.creator),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.people),
                      tooltip: 'Roster',
                      onPressed: () => onRoster(cls),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete Class',
                      onPressed: () => onDelete(cls),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------- STUDENT ENROLLMENT ----------------
class _StudentEnrollmentPanel extends StatelessWidget {
  final String? studentId;
  final List<Classroom> enrolled;
  final void Function(Classroom) onEnroll;
  final void Function(Classroom) onUnenroll;

  const _StudentEnrollmentPanel({
    required this.studentId,
    required this.enrolled,
    required this.onEnroll,
    required this.onUnenroll,
  });

  @override
  Widget build(BuildContext context) {
    if (studentId == null) {
      return const Center(
        child: Text('Search a student to manage enrollment'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Classes for $studentId',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: enrolled.isEmpty
              ? const Center(child: Text('No enrolled classes'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: enrolled.length,
                  itemBuilder: (_, i) {
                    final cls = enrolled[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(cls.className),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => onUnenroll(cls),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
