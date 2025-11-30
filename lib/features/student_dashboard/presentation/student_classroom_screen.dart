// lib/features/student_dashboard/presentation/student_classroom_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/features/student_dashboard/presentation/student_classroom_page.dart';
import 'package:ace/services/class_service.dart';

class StudentClassroomScreen extends StatefulWidget {
  @override
  _StudentClassroomState createState() => _StudentClassroomState();
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

  // Utility to fetch the logged-in student's ID
  String? _getStudentId() {
    try {
      final box = Hive.box("_loginbox");
      return box.get("User");
    } catch (e) {
      print("Error retrieving student ID from Hive: $e");
      return null;
    }
  }

  // Load the classes based on the logged-in student ID
  void _initializeClasses() {
    _studentId = _getStudentId();
    if (_studentId != null) {
      _classesFuture = _classService.fetchStudentClasses(_studentId!);
    } else {
      // If student ID is missing, set a future that returns an empty list
      _classesFuture = Future.value([]);
      print("Student ID is null. Cannot fetch classes.");
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
                'Error loading classes: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final classRoomList = snapshot.data ?? [];

          if (classRoomList.isEmpty) {
            return Center(
              child: Text(
                _studentId == null
                    ? 'Please log in to see your classes.'
                    : 'You are currently not enrolled in any classes.',
                style: TextStyle(
                    color: ColorPalette.secondary.withOpacity(0.8),
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Display the list of enrolled classes
          return ListView.builder(
              itemCount: classRoomList.length,
              itemBuilder: (context, index) {
                final classData = classRoomList[index];
                return ListTile(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => StudentClassroomPage(
                            classroom: classData,
                          ))),
                  title: Stack(
                    children: [
                      Container(
                        height: 140,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.orange,
                        ),
                        child: Image(
                          image: AssetImage(classData.bannerImgPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30, left: 30),
                        width: 220,
                        child: Text(
                          classData.className,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 58, left: 30),
                        child: Text(
                          classData.description,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 1),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 125, left: 30),
                        child: Text(
                          classData.creator,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                              letterSpacing: 1),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20, left: 370),
                        child: IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          splashColor: Colors.white54,
                          onPressed: () {},
                          iconSize: 25,
                        ),
                      )
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
