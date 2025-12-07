// lib/features/admin_dashboard/presentation/admin_account_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'dart:convert';
import 'package:ace/features/shared/widget/personal_info_section.dart';
import 'package:ionicons/ionicons.dart';

class AdminAccount extends StatefulWidget {
  const AdminAccount({super.key});

  @override
  State<AdminAccount> createState() => _AdminAccountState();
}

class _AdminAccountState extends State<AdminAccount> {
  DateTime backPressedTime = DateTime.now();
  final _loginbox = Hive.box("_loginbox");
  late var adminId = _loginbox.get("User"); // ID used as key for Firebase

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to respect status bar
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: ColorPalette.accentBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getAdminUserWithStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: ColorPalette.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
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
                  const Text(
                    "Something went wrong",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please try again.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
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
          final totalClasses = data['totalClasses'] as int;
          final totalStudents = data['totalStudents'] as int;

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: topPadding, bottom: 24),
            child: Column(
              children: [
                PersonalInfoSection(
                  user: user,
                  role: "Administrator",
                  avatarIcon: Icons.admin_panel_settings_outlined,
                  isAdmin: true,
                  statValue1: totalClasses,
                  statLabel1: 'Total Classes',
                  statIcon1: Ionicons.file_tray_stacked_outline,
                  statValue2: totalStudents,
                  statLabel2: 'Total Students',
                  statIcon2: Ionicons.people_outline,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Fetch admin user data along with statistics
  Future<Map<String, dynamic>> _getAdminUserWithStats() async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("Admins/$adminId");

    try {
      print('[DEBUG] Fetching admin data for: $adminId');

      // Fetch admin user data
      DataSnapshot snapshot = await databaseReference.get();
      if (!snapshot.exists || snapshot.value == null) {
        print('[ERROR] Admin data not found for $adminId');
        throw Exception("Admin data not found for $adminId.");
      }

      print('[DEBUG] Admin data fetched successfully');
      Map<String, dynamic> myObj = jsonDecode(jsonEncode(snapshot.value));
      User myUserObj = User.fromJson(myObj);

      // Initialize statistics
      int totalClasses = 0;
      int totalStudents = 0;
      Set<String> uniqueStudents = {};

      try {
        print('[DEBUG] Querying all classes in the system');

        // Query all classes (admin oversees all classes)
        DataSnapshot allClassesSnapshot =
            await FirebaseDatabase.instance.ref().child('Classes').get();

        if (allClassesSnapshot.exists && allClassesSnapshot.value != null) {
          if (allClassesSnapshot.value is Map) {
            final allClasses = allClassesSnapshot.value as Map;

            // Count all classes
            for (var entry in allClasses.entries) {
              final classId = entry.key;
              final classData = Map<String, dynamic>.from(entry.value as Map);

              totalClasses++;
              print(
                  '[DEBUG] Found class: $classId (${classData['className'] ?? 'Unknown'})');

              // Get students in this class
              try {
                if (classData.containsKey('students') &&
                    classData['students'] is Map) {
                  final students = classData['students'] as Map;
                  final studentIds = students.keys.cast<String>().toList();
                  uniqueStudents.addAll(studentIds);
                  print(
                      '[DEBUG] Class $classId has ${studentIds.length} students');
                }
              } catch (e) {
                print(
                    '[WARNING] Error extracting students for class $classId: $e');
              }
            }
          }
        }

        totalStudents = uniqueStudents.length;
        print(
            '[DEBUG] Admin oversees $totalClasses classes with $totalStudents unique students');
      } catch (e) {
        print('[WARNING] Error fetching admin statistics: $e');
        // Keep default values of 0
      }

      print('[DEBUG] Successfully prepared admin data with stats');
      return {
        'user': myUserObj,
        'totalClasses': totalClasses,
        'totalStudents': totalStudents,
      };
    } catch (error) {
      print('[ERROR] Fatal error in _getAdminUserWithStats: $error');
      rethrow;
    }
  }
}
