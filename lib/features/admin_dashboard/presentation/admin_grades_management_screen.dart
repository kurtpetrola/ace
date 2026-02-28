// lib/features/admin_dashboard/presentation/admin_grades_management_screen.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ace/common/widgets/grades_table.dart';
import 'package:ace/common/widgets/common_search_bar.dart';
import 'package:ace/services/grade_service.dart';
import 'package:ace/features/admin_dashboard/presentation/widgets/add_grade_form.dart';

class AdminGradesManagementScreen extends StatefulWidget {
  const AdminGradesManagementScreen({super.key});

  @override
  State<AdminGradesManagementScreen> createState() =>
      _AdminGradesManagementScreenState();
}

class _AdminGradesManagementScreenState
    extends State<AdminGradesManagementScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final GradeService _gradeService = GradeService();

  Map<String, dynamic>? _studentGrades;
  String? _currentStudentId;
  String _message = 'Enter a Student ID and press Search.';
  bool _isLoading = false;

  // --- Grade Search Logic ---
  Future<void> _searchStudent() async {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      setState(() {
        _message = 'Please enter a Student ID.';
        _studentGrades = null;
        _currentStudentId = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Validating student account...';
      _studentGrades = null;
      _currentStudentId = null;
    });

    try {
      final exists = await _gradeService.checkStudentExists(studentId);
      if (!exists) {
        setState(() {
          _message =
              'Error: Student ID "$studentId" not found in the database.';
          _studentGrades = null;
          _currentStudentId = null;
        });
        return;
      }

      setState(() {
        _message = 'Student account confirmed. Fetching grades...';
      });

      final grades = await _gradeService.fetchStudentGrades(studentId);

      setState(() {
        _studentGrades = grades ?? {};
        _message = _studentGrades!.isNotEmpty
            ? 'Grades found for $studentId.'
            : 'Student account found. No grades registered yet.';
        _currentStudentId = studentId;
      });
    } catch (e) {
      setState(() {
        _message = 'An unexpected error occurred during search.';
        _studentGrades = null;
        _currentStudentId = null;
      });
      if (kDebugMode) log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Admin Grade Oversight',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // --- SEARCH BAR (replicated from AdminClassManagement) ---
            CommonSearchBar(
              controller: _studentIdController,
              onSearch: _searchStudent,
              statusText: _message,
              // CommonSearchBar doesn't have isLoading prop yet, but blocking interaction logic is inside onSearch/Controller if needed
              // or we can just let it be. The visual consistency is more important here.
            ),

            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildGradesView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesView() {
    if (_currentStudentId == null) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_studentGrades != null && _studentGrades!.isNotEmpty) ...[
          const Divider(height: 30, thickness: 1),
          Text(
            'Current Grades',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          GradeTable(grades: _studentGrades!),
          const Divider(height: 30, thickness: 1),
        ],
        AddGradeForm(studentId: _currentStudentId!),
      ],
    );
  }
}

// ---------------- REUSABLE STUDENT SEARCH BAR REMOVED ----------------
