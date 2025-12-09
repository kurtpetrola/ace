// lib/features/teacher_dashboard/presentation/teacher_classes_screen.dart

import 'package:flutter/material.dart';

import 'package:ace/models/classroom.dart';
import 'package:ace/services/class_service.dart';
import 'package:ace/features/teacher_dashboard/presentation/teacher_classroom_page.dart';

import 'package:ionicons/ionicons.dart';

class TeacherClassesScreen extends StatefulWidget {
  final String teacherId;

  const TeacherClassesScreen({super.key, required this.teacherId});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  final ClassService _classService = ClassService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Classes',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Manage your coursework and view submissions',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
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
                          'No classes assigned yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Contact an admin to assign classes to you.',
                          style: TextStyle(color: Colors.grey),
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
                    return Container(
                      height: 160,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(classroom.bannerImgPath),
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeacherClassroomPage(
                                  classroom: classroom,
                                  teacherId: widget.teacherId,
                                ),
                              ),
                            );
                          },
                          child: Padding(
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
                                        classroom.className,
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
                                  classroom.description,
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
                                    classroom.creator,
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
                        ),
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
