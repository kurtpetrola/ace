// lib/features/admin_dashboard/presentation/admin_account_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'dart:convert';
import 'package:ace/features/shared/widget/personal_info_section.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/theme/theme_provider.dart';

class AdminAccount extends ConsumerStatefulWidget {
  const AdminAccount({super.key});

  @override
  ConsumerState<AdminAccount> createState() => _AdminAccountState();
}

class _AdminAccountState extends ConsumerState<AdminAccount> {
  DateTime backPressedTime = DateTime.now();
  final _loginbox = Hive.box("_loginbox");
  late var adminId = _loginbox.get("User"); // ID used as key for Firebase

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
        future: _getAdminUserWithStats(),
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
                    "Please try again.",
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
          final totalClasses = data['totalClasses'] as int;
          final totalStudents = data['totalStudents'] as int;

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: topPadding, bottom: 60),
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
                ),
                const SizedBox(height: 16),
                _buildDarkModeToggle(context),
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
