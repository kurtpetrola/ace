// lib/features/student_dashboard/presentation/student_classroom_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/features/student_dashboard/presentation/student_classroom_page.dart';
import 'package:ace/services/class_service.dart';

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
    return Scaffold(
      backgroundColor: ColorPalette.accentBlack,
      body: FutureBuilder<List<Classroom>>(
        future: _classesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading classes:\n${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final classrooms = snapshot.data ?? [];

          if (classrooms.isEmpty) {
            return Center(
              child: Text(
                _studentId == null
                    ? 'Please log in to view your classes.'
                    : 'You are not enrolled in any classes yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorPalette.secondary.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              final classData = classrooms[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
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
                title: Stack(
                  children: [
                    Container(
                      height: 140,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[800],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          classData.bannerImgPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 30,
                      right: 56,
                      child: Text(
                        classData.className,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 30,
                      right: 56,
                      child: Text(
                        classData.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 30,
                      child: Text(
                        classData.creator,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
