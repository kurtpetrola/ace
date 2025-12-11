// lib/features/student_dashboard/presentation/student_grade_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/services/grade_service.dart';
import 'package:ace/features/shared/widget/grades_table.dart';

// ----------------------------------------------------
// 1. Riverpod Service and Provider Definitions
// ----------------------------------------------------

// Instantiate the GradeService once for the application
final gradeService = GradeService();

/// A Family StreamProvider that connects to Firebase Realtime DB.
final studentGradesStreamProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, studentId) {
  return gradeService.getStudentGradesStreamCached(studentId);
});

/// A Family Provider that processes the raw DatabaseEvent into a clean Map of grades.
/// This is the provider the UI will consume.
final gradesDataProvider =
    Provider.family<Map<String, dynamic>, String>((ref, studentId) {
  // 1. Watch the stream provider (now returns Map)
  final gradesStreamAsync = ref.watch(studentGradesStreamProvider(studentId));

  // 2. Process the AsyncValue state
  return gradesStreamAsync.when(
    loading: () => {}, // Return empty map while loading
    error: (err, stack) {
      debugPrint('Error fetching grades: $err');
      return {}; // Return empty map on error
    },
    data: (data) => data, // Pass through the Map directly
  );
});

// ----------------------------------------------------
// 2. Grade View (The UI)
// ----------------------------------------------------

class GradesView extends ConsumerWidget {
  final String studentId;

  const GradesView({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grades = ref.watch(gradesDataProvider(studentId));
    final loadingState = ref.watch(studentGradesStreamProvider(studentId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: loadingState.isLoading && grades.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildGradesContent(context, grades),
    );
  }

  Widget _buildGradesContent(
      BuildContext context, Map<String, dynamic> grades) {
    if (grades.isEmpty) {
      return Center(
          child: Text("No grades found.",
              style: Theme.of(context).textTheme.bodyLarge));
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: GradeTable(grades: grades),
      ),
    );
  }
}
