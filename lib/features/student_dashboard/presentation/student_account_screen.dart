// lib/features/student_dashboard/presentation/student_account_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:ace/models/user.dart';
import 'package:ace/features/shared/widget/personal_info_section.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/theme/theme_provider.dart';

class StudentAccountScreen extends ConsumerStatefulWidget {
  const StudentAccountScreen({super.key});

  @override
  ConsumerState<StudentAccountScreen> createState() =>
      _StudentAccountScreenState();
}

class _StudentAccountScreenState extends ConsumerState<StudentAccountScreen> {
  final _loginbox = Hive.box("_loginbox");
  late var fullname = _loginbox.get("User");

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to respect status bar
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserWithStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            print('[ERROR] UI Error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Something went wrong",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please check the console for details",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final user = data['user'] as User;
          final enrolledClassesCount = data['enrolledClasses'] as int;
          final pendingAssignments = data['pendingAssignments'] as int;

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: topPadding, bottom: 24),
            child: Column(
              children: [
                PersonalInfoSection(
                  user: user,
                  role: "Student",
                  avatarIcon: Icons.school_outlined,
                  isAdmin: false,
                  statValue1: enrolledClassesCount,
                  statLabel1: 'Enrolled Classes',
                  statIcon1: Ionicons.book_outline,
                  statValue2: pendingAssignments,
                  statLabel2: 'Pending Work',
                  statIcon2: Ionicons.time_outline,
                ),
                const SizedBox(height: 24),
                _buildDarkModeToggle(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fetch user data along with statistics
  Future<Map<String, dynamic>> _getUserWithStats() async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("Students/$fullname");

    try {
      print('[DEBUG] Fetching student data for: $fullname');

      // Fetch user data
      DataSnapshot snapshot = await databaseReference.get();
      if (!snapshot.exists || snapshot.value == null) {
        print('[ERROR] Student data not found for $fullname');
        throw Exception("Student data not found for $fullname.");
      }

      print('[DEBUG] Student data fetched successfully');
      Map<String, dynamic> myObj = jsonDecode(jsonEncode(snapshot.value));
      User myUserObj = User.fromJson(myObj);

      // Initialize with default values
      int enrolledClassesCount = 0;
      int pendingAssignments = 0;

      // Fetch enrolled classes count (with error handling)
      try {
        print('[DEBUG] Fetching enrolled classes...');
        DataSnapshot classesSnapshot =
            await databaseReference.child('classes').get();
        if (classesSnapshot.exists && classesSnapshot.value != null) {
          if (classesSnapshot.value is Map) {
            enrolledClassesCount = (classesSnapshot.value as Map).keys.length;
            print('[DEBUG] Found $enrolledClassesCount enrolled classes');

            // Fetch pending assignments (classwork with no submission)
            try {
              print('[DEBUG] Fetching pending assignments...');
              final classIds = (classesSnapshot.value as Map).keys.toList();

              for (var classId in classIds) {
                try {
                  // Get classwork references for this class
                  // Classes/{classId}/classwork contains: { "classworkId": true }
                  DataSnapshot classworkRefsSnapshot = await FirebaseDatabase
                      .instance
                      .ref()
                      .child('Classes/$classId/classwork')
                      .get();

                  if (classworkRefsSnapshot.exists &&
                      classworkRefsSnapshot.value != null) {
                    if (classworkRefsSnapshot.value is Map) {
                      final classworkIds =
                          (classworkRefsSnapshot.value as Map).keys.toList();

                      print(
                          '[DEBUG] Found ${classworkIds.length} classwork items in class $classId');

                      for (var classworkId in classworkIds) {
                        try {
                          // Check if student has submitted
                          DataSnapshot submissionSnapshot =
                              await FirebaseDatabase.instance
                                  .ref()
                                  .child('submissions/$classworkId/$fullname')
                                  .get();

                          if (!submissionSnapshot.exists) {
                            pendingAssignments++;
                            print('[DEBUG] Pending classwork: $classworkId');
                          }
                        } catch (e) {
                          print(
                              '[WARNING] Error checking submission for classwork $classworkId: $e');
                          // Continue to next classwork
                        }
                      }
                    }
                  }
                } catch (e) {
                  print(
                      '[WARNING] Error fetching classwork for class $classId: $e');
                  // Continue to next class
                }
              }
              print('[DEBUG] Found $pendingAssignments pending assignments');
            } catch (e) {
              print('[WARNING] Error calculating pending assignments: $e');
              // Set to 0 if there's an error
              pendingAssignments = 0;
            }
          }
        } else {
          print('[DEBUG] No classes found for student');
        }
      } catch (e) {
        print('[WARNING] Error fetching classes: $e');
        // Keep default values of 0
      }

      print('[DEBUG] Successfully prepared user data with stats');
      return {
        'user': myUserObj,
        'enrolledClasses': enrolledClassesCount,
        'pendingAssignments': pendingAssignments,
      };
    } catch (error) {
      print('[ERROR] Fatal error in _getUserWithStats: $error');
      rethrow;
    }
  }

  /// Build dark mode toggle widget
  Widget _buildDarkModeToggle(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDarkMode ? Ionicons.moon : Ionicons.sunny,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDarkMode ? 'Enabled' : 'Disabled',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isDarkMode,
            onChanged: (_) => themeNotifier.toggleTheme(),
            activeColor: ColorPalette.primary,
          ),
        ],
      ),
    );
  }
}
