// lib/features/teacher_dashboard/presentation/teacher_grades_screen.dart

import 'package:flutter/material.dart';

import 'package:ace/models/classroom.dart';
import 'package:ace/services/class_service.dart';
import 'package:ace/features/teacher_dashboard/presentation/teacher_gradebook_screen.dart';
import 'package:ionicons/ionicons.dart';

class TeacherGradesScreen extends StatefulWidget {
  final String teacherId;

  const TeacherGradesScreen({super.key, required this.teacherId});

  @override
  State<TeacherGradesScreen> createState() => _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends State<TeacherGradesScreen> {
  final ClassService _classService = ClassService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Or theme background
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Header implementation since we're inside a TabView and might utilize the main scaffold's app bar or a custom one
          // But normally tabs have their own body.
          // Student Dashboard has a shared App Bar with dynamic title. Teacher Dashboard will likely do the same.
          // So this widget just provides the body content.

          Expanded(
            child: StreamBuilder<List<Classroom>>(
              stream: _classService.streamTeacherClasses(widget.teacherId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final classes = snapshot.data ?? [];

                if (classes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Ionicons.school_outline,
                            size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No classes to grade',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final classroom = classes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Ionicons.stats_chart,
                              color: Theme.of(context).primaryColor),
                        ),
                        title: Text(
                          classroom.className,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                            '${classroom.description}\nCreator: ${classroom.creator}'),
                        trailing: const Icon(Ionicons.chevron_forward),
                        onTap: () {
                          // Navigate to Classwork/Gradebook
                          // For now, re-using Classwork screen but usually this would go to a specific gradebook view
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherGradebookScreen(
                                classroom: classroom,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
