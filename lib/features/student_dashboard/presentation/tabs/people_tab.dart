// lib/features/student_dashboard/presentation/tabs/people_tab.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/user.dart';
import 'package:ace/services/class_service.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ionicons/ionicons.dart';

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

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Divider(color: color.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildPersonCard(User user, {bool isTeacher = false}) {
    final initials = user.fullname.isNotEmpty ? user.fullname[0] : '?';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isTeacher
              ? ColorPalette.primary.withOpacity(0.1)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isTeacher
              ? ColorPalette.primary.withOpacity(0.1)
              : Colors.grey.shade100,
          child: Text(
            initials.toUpperCase(),
            style: TextStyle(
              color: isTeacher ? ColorPalette.primary : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.fullname,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: ColorPalette.accentBlack,
          ),
        ),
        subtitle: isTeacher
            ? const Text(
                'Class Teacher',
                style: TextStyle(color: ColorPalette.primary, fontSize: 13),
              )
            : null,
        trailing: isTeacher
            ? IconButton(
                onPressed: () {},
                icon: const Icon(Ionicons.mail_outline,
                    color: ColorPalette.primary),
              )
            : null,
      ),
    );
  }

  // Helper for static teacher entry since Classroom only has a string name
  Widget _buildTeacherCard(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: ColorPalette.primary.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: ColorPalette.primary.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'T',
            style: const TextStyle(
              color: ColorPalette.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ColorPalette.accentBlack,
          ),
        ),
        subtitle: const Text(
          'Class Creator',
          style: TextStyle(color: ColorPalette.primary, fontSize: 13),
        ),
        trailing: IconButton(
          onPressed: () {}, // Future: Email logic
          icon: const Icon(Ionicons.mail_outline, color: ColorPalette.primary),
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
          // --- Teachers Section ---
          _buildSectionHeader('Teachers', ColorPalette.primary),
          _buildTeacherCard(widget.classroom.creator),
          const SizedBox(height: 12),

          // --- Classmates Section ---
          _buildSectionHeader('Classmates', ColorPalette.secondary),
          Text(
            '${_students.length} students',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          if (_students.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Ionicons.people_outline,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No other students yet',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._students.map((student) => _buildPersonCard(student)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
