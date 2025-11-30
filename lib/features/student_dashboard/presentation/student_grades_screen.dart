// lib/features/student_dashboard/presentation/student_grade_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/services/grade_service.dart';

// ----------------------------------------------------
// 1. Riverpod Service and Provider Definitions
// ----------------------------------------------------

// Instantiate the GradeService once for the application
final gradeService = GradeService();

/// A Family StreamProvider that connects to Firebase Realtime DB.
/// It takes the studentId as a parameter.
final studentGradesStreamProvider =
    StreamProvider.family<DatabaseEvent, String>((ref, studentId) {
  // Use the service to get the real-time stream for the specific student
  return gradeService.getStudentGradesStream(studentId);
});

/// A Family Provider that processes the raw DatabaseEvent into a clean Map of grades.
/// This is the provider the UI will consume.
final gradesDataProvider =
    Provider.family<Map<String, dynamic>, String>((ref, studentId) {
  // 1. Watch the real-time stream provider
  final gradesStreamAsync = ref.watch(studentGradesStreamProvider(studentId));

  // 2. Process the AsyncValue state
  return gradesStreamAsync.when(
    loading: () => {}, // Return empty map while loading
    error: (err, stack) {
      debugPrint('Error fetching grades: $err');
      return {}; // Return empty map on error
    },
    data: (event) {
      if (event.snapshot.value != null) {
        // Deserialize the data into a clean Map<String, dynamic>
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          return Map<String, dynamic>.from(data);
        }
      }
      return {}; // Empty grades map
    },
  );
});

// ----------------------------------------------------
// 2. Grade View (The UI) - Now a ConsumerWidget
// ----------------------------------------------------

// GradesView must now accept the studentId passed down from the parent (HomeScreenPage)
class GradesView extends ConsumerWidget {
  final String studentId;
  const GradesView({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the processed grades data provider
    final grades = ref.watch(gradesDataProvider(studentId));

    // Also watch the original stream for the loading state (only for the first load)
    final loadingState = ref.watch(studentGradesStreamProvider(studentId));

    return Scaffold(
      backgroundColor: ColorPalette.accentBlack,
      body: loadingState.isLoading && grades.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildGradesContent(context, grades),
    );
  }

  Widget _buildGradesContent(
      BuildContext context, Map<String, dynamic> grades) {
    if (grades.isEmpty) {
      return const Center(
          child:
              Text("No grades found.", style: TextStyle(color: Colors.white)));
    }

    // Convert the Map to a list of DataRow for the table
    final List<DataRow> rows = grades.entries.map((entry) {
      final subjectCode = entry.key;
      // Ensure entry.value is treated as a Map<String, dynamic>
      final gradeDetails = Map<String, dynamic>.from(entry.value as Map);

      // Assuming 'Final' or similar key holds the main grade. Adjust as needed.
      final finalGrade = gradeDetails['Final'] ?? gradeDetails['P3'] ?? 'N/A';

      return DataRow(cells: [
        DataCell(Text(subjectCode)),
        DataCell(Text(finalGrade,
            style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(gradeDetails['P1'] ?? '-')),
        DataCell(Text(gradeDetails['P2'] ?? '-')),
        DataCell(Text(gradeDetails['P3'] ?? '-')),
      ]);
    }).toList();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                      label: Text('Course Code',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('FINAL',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.secondary))),
                  DataColumn(label: Text('P1')),
                  DataColumn(label: Text('P2')),
                  DataColumn(label: Text('P3')),
                ],
                rows: rows,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
