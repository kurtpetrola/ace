// lib/features/student_dashboard/presentation/student_classroom_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/features/student_dashboard/presentation/student_classroom_page.dart';
import 'package:ace/services/class_service.dart';
import 'package:ionicons/ionicons.dart';

class StudentClassroomScreen extends StatefulWidget {
  const StudentClassroomScreen({super.key});

  @override
  State<StudentClassroomScreen> createState() => _StudentClassroomState();
}

class _StudentClassroomState extends State<StudentClassroomScreen> {
  final ClassService _classService = ClassService();

  String? _studentId;
  Future<List<Classroom>>? _classesFuture;

  @override
  void initState() {
    super.initState();
    _initializeClasses();
  }

  /// Fetch logged-in student ID from Hive
  String? _getStudentId() {
    try {
      final box = Hive.box('_loginbox');
      return box.get('User');
    } catch (e) {
      debugPrint('Error retrieving student ID: $e');
      return null;
    }
  }

  /// Load enrolled classes for the student
  void _initializeClasses() {
    _studentId = _getStudentId();

    if (_studentId != null) {
      _classesFuture = _classService.fetchStudentClasses(_studentId!);
    } else {
      _classesFuture = Future.value([]);
      debugPrint('Student ID is null. Cannot fetch classes.');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyStateColor =
        isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    final emptyStateTextColor =
        isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<List<Classroom>>(
        future: _classesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Ionicons.alert_circle_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading classes:\n${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final classrooms = snapshot.data ?? [];

          if (classrooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Ionicons.school_outline,
                      size: 80, color: emptyStateColor),
                  const SizedBox(height: 20),
                  Text(
                    'No enrolled classes yet',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join a class to get started',
                    style: TextStyle(
                      color: emptyStateTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _initializeClasses(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: classrooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final classData = classrooms[index];

                return GestureDetector(
                  onTap: () {
                    if (_studentId == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StudentClassroomPage(
                          classroom: classData,
                          studentId: _studentId!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(classData.bannerImgPath),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      classData.className,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          )
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.more_vert,
                                      color: Colors.white),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                classData.description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  classData.creator,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
