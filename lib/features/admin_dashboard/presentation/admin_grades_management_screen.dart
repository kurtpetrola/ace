// lib/features/admin_dashboard/presentation/admin_grades_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/services/grade_service.dart';
import 'package:flutter/foundation.dart';
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
      // 1. VALIDATE STUDENT EXISTENCE FIRST
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

      // 2. If student exists, proceed to fetch grades
      setState(() {
        _message = 'Student account confirmed. Fetching grades...';
      });

      final grades = await _gradeService.fetchStudentGrades(studentId);

      setState(() {
        _studentGrades = grades ?? {};
        _message = _studentGrades!.isNotEmpty
            ? 'Grades found for $studentId.'
            : 'Student account found. No grades registered yet.';
        // Set the ID only on successful confirmation and fetch
        _currentStudentId = studentId;
      });
    } catch (e) {
      setState(() {
        _message = 'An unexpected error occurred during search.';
        _studentGrades = null;
        _currentStudentId = null;
      });
      if (kDebugMode) print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Admin Grade Oversight',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorPalette.secondary,
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Search Student ID',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty && _currentStudentId != null) {
                        setState(() {
                          _currentStudentId = null;
                          _studentGrades = null;
                          _message = 'Enter a Student ID and press Search.';
                        });
                      }
                    },
                    onSubmitted: (_) => _searchStudent(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  color: ColorPalette.secondary,
                  onPressed: _isLoading ? null : _searchStudent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorPalette.secondary.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
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

  // Method to combine the current grades table and the grade form
  Widget _buildGradesView() {
    if (_currentStudentId == null) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Current Grades Table (If grades exist)
        if (_studentGrades != null && _studentGrades!.isNotEmpty) ...[
          const Divider(height: 30, thickness: 1),
          const Text(
            'Current Grades',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorPalette.accentBlack,
            ),
          ),
          const SizedBox(height: 10),
          _buildGradesTable(),
          const Divider(height: 30, thickness: 1),
        ],

        // 2. The Grade Input Form (Always shown if student ID is successfully validated)
        AddGradeForm(studentId: _currentStudentId!),
      ],
    );
  }

  // Builds the table of subjects
  Widget _buildGradesTable() {
    final List<DataRow> rows = _studentGrades!.entries.map((entry) {
      final subjectCode = entry.key;
      final gradeDetails = entry.value is Map
          ? Map<String, dynamic>.from(entry.value)
          : <String, dynamic>{};

      final latestGrade = gradeDetails['Final'] ??
          gradeDetails['P3'] ??
          gradeDetails['P2'] ??
          gradeDetails['P1'] ??
          'N/A';

      return DataRow(cells: [
        DataCell(Text(subjectCode)),
        DataCell(Text(latestGrade.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(gradeDetails['P1']?.toString() ?? '-')),
        DataCell(Text(gradeDetails['P2']?.toString() ?? '-')),
        DataCell(Text(gradeDetails['P3']?.toString() ?? '-')),
        DataCell(Text(gradeDetails['Final']?.toString() ?? '-')),
      ]);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text('Course Code',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Latest',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.secondary))),
          DataColumn(label: Text('P1')),
          DataColumn(label: Text('P2')),
          DataColumn(label: Text('P3')),
          DataColumn(label: Text('Final')),
        ],
        rows: rows,
      ),
    );
  }
}
