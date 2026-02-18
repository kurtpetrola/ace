// lib/features/teacher_dashboard/presentation/teacher_account_screen.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/core/theme/theme_provider.dart';
import 'package:ace/common/widgets/personal_info_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/models/user.dart';
import 'dart:convert';

class TeacherAccountScreen extends ConsumerStatefulWidget {
  final String teacherId;
  const TeacherAccountScreen({super.key, required this.teacherId});

  @override
  ConsumerState<TeacherAccountScreen> createState() =>
      _TeacherAccountScreenState();
}

class _TeacherAccountScreenState extends ConsumerState<TeacherAccountScreen> {
  // Assuming the logged in user ID is stored or passed.
  // We utilize widget.teacherId which should be consistent with the logged in user.

  @override
  Widget build(BuildContext context) {
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
        future: _getTeacherWithStats(),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final user = data['user'] as User;
          final classesCount = data['classesCount'] as int;
          // You could add more stats here like "Total Students" if efficiently queryable

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: topPadding, bottom: 60),
            child: Column(
              children: [
                PersonalInfoSection(
                  user: user,
                  role: 'Teacher',
                  avatarIcon: Icons.school,
                  isAdmin: false,
                  statValue1: classesCount,
                  statLabel1: 'Active Classes',
                  statIcon1: Ionicons.book_outline,
                  statValue2: 0, // Placeholder
                  statLabel2: 'Pending Reviews', // Future feature
                  statIcon2: Ionicons.time_outline,
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

  Future<Map<String, dynamic>> _getTeacherWithStats() async {
    // We use the ID passed to the widget.
    // However, the database key for teachers is effectively the teacherId based on our recent change,
    // OR it's the UID. Our recent change made the key 'TCH-001' etc.
    // So we query `Teachers/$teacherId`.

    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('Teachers/${widget.teacherId}');

    try {
      final DataSnapshot snapshot = await dbRef.get();
      if (!snapshot.exists || snapshot.value == null) {
        throw Exception('Teacher data not found for ${widget.teacherId}');
      }

      final Map<String, dynamic> userMap =
          jsonDecode(jsonEncode(snapshot.value));
      final User user = User.fromJson(userMap);

      // Get classes count
      // Option 1: Query 'Classes' node filtering by teacherId (expensive if many classes)
      // Option 2: If we store a list of class IDs under the teacher (not currently doing this)
      // We will do Option 1 for now as per ClassService logic.
      int classesCount = 0;
      final classesSnap = await FirebaseDatabase.instance
          .ref()
          .child('Classes')
          .orderByChild('teacherId')
          .equalTo(widget.teacherId)
          .get();

      if (classesSnap.exists) {
        classesCount = classesSnap.children.length;
      }

      return {
        'user': user,
        'classesCount': classesCount,
      };
    } catch (e) {
      rethrow;
    }
  }

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
            color: Colors.black.withValues(alpha: 0.05),
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
            activeThumbColor: ColorPalette.primary,
          ),
        ],
      ),
    );
  }
}
