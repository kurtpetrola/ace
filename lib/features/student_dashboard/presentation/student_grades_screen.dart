// lib/features/student_dashboard/presentation/student_grade_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/services/grade_service.dart';
import 'package:ace/features/shared/widget/grades_table.dart';
import 'package:ace/services/classwork_service.dart';
import 'package:ace/services/submission_service.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/models/submission.dart';
import 'package:ace/features/student_dashboard/presentation/widgets/pending_grades_list.dart';
import 'package:ace/features/student_dashboard/presentation/widgets/recently_graded_list.dart';

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
// 2. Pending Grades Provider
// ----------------------------------------------------

final classworkService = ClassworkService();
final submissionService = SubmissionService();

final pendingGradesProvider =
    FutureProvider.family<List<Classwork>, String>((ref, studentId) async {
  // 1. Fetch all classwork for student
  final allClasswork =
      await classworkService.fetchClassworkForStudent(studentId);

  // 2. Filter for pending
  final List<Classwork> pending = [];

  for (final cw in allClasswork) {
    final submission =
        await submissionService.getStudentSubmission(cw.classworkId, studentId);
    // If submitted but grade is null, it's pending
    if (submission != null && submission.grade == null) {
      pending.add(cw);
    }
  }

  return pending;
});

// ----------------------------------------------------
// 3. Recently Graded Provider
// ----------------------------------------------------

final recentlyGradedProvider = FutureProvider.family<
    Map<String,
        dynamic>, // Returns {'classwork': List<Classwork>, 'submissions': Map<String, Submission>}
    String>((ref, studentId) async {
  // 1. Fetch all classwork
  final allClasswork =
      await classworkService.fetchClassworkForStudent(studentId);

  final List<Classwork> graded = [];
  final Map<String, Submission> submissionMap = {};

  for (final cw in allClasswork) {
    final submission =
        await submissionService.getStudentSubmission(cw.classworkId, studentId);

    // Check if showing graded
    if (submission != null && submission.grade != null) {
      graded.add(cw);
      submissionMap[cw.classworkId] = submission;
    }
  }

  // Sort by submission date (most recent first) - approximate using createdAt or actual submission date if available in future
  // For now, let's sort by classwork createdAt as proxy if submission date is not easily available in list sort
  // Actually we have the submission object, let's use submittedAt
  graded.sort((a, b) {
    final subA = submissionMap[a.classworkId]!.submittedAt;
    final subB = submissionMap[b.classworkId]!.submittedAt;
    return subB.compareTo(subA); // Descending
  });

  // Take top 5
  final top5 = graded.take(5).toList();

  return {
    'classwork': top5,
    'submissions': submissionMap,
  };
});

// ----------------------------------------------------
// 3. Grade View (The UI)
// ----------------------------------------------------

class GradesView extends ConsumerWidget {
  final String studentId;

  const GradesView({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grades = ref.watch(gradesDataProvider(studentId));
    final loadingState = ref.watch(studentGradesStreamProvider(studentId));
    final pendingGradesAsync = ref.watch(pendingGradesProvider(studentId));
    final recentlyGradedAsync = ref.watch(recentlyGradedProvider(studentId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Grades Section
            pendingGradesAsync.when(
              data: (pending) => PendingGradesList(pendingClasswork: pending),
              loading: () => const SizedBox
                  .shrink(), // Don't show anything while loading pending
              error: (err, stack) => const SizedBox.shrink(),
            ),

            // Recently Graded Section
            recentlyGradedAsync.when(
              data: (data) => RecentlyGradedList(
                classworkList: data['classwork'] as List<Classwork>,
                submissionMap: data['submissions'] as Map<String, Submission>,
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),

            // Term Grades Section
            if (loadingState.isLoading && grades.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              _buildGradesContent(context, grades),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesContent(
      BuildContext context, Map<String, dynamic> grades) {
    if (grades.isEmpty) {
      return Center(
          child: Text("No term grades found.",
              style: Theme.of(context).textTheme.bodyLarge));
    }

    return Container(
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
    );
  }
}
