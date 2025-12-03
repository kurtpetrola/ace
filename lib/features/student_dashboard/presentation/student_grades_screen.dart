// lib/features/student_dashboard/presentation/student_grade_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
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
    StreamProvider.family<DatabaseEvent, String>((ref, studentId) {
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

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: GradeTable(grades: grades),
      ),
    );
  }
}
