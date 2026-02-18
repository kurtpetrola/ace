// lib/features/auth/wrapper_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/student_dashboard/presentation/student_homescreen_page.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_homescreen_page.dart';
import 'package:ace/features/teacher_dashboard/presentation/teacher_dashboard.dart';
import 'dart:developer';

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  final _loginbox = Hive.box('_loginbox');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToDashboard();
    });
  }

  // --- Core Routing Logic ---
  Future<void> _navigateToDashboard() async {
    final userId = _loginbox.get('User'); // Get the user key
    final userType =
        _loginbox.get('UserType'); // Get the type (e.g., "Admin", "Student")

    // Log the user context for debugging
    log('WrapperScreen: Attempting to navigate for User ID: $userId, Type: $userType');

    // Guard clause: ensure we have a user ID
    if (userId == null || userId.isEmpty) {
      return _handleError('User ID not found in Hive. Forced logout.');
    }

    // --- OFFLINE-FIRST ROUTING STRATEGY ---
    // 1. Check cached UserType first (Instant Route)
    if (userType != null) {
      Widget destinationPage;

      if (userType == 'Admin') {
        destinationPage = const AdminHomeScreenPage();
      } else if (userType == 'Teacher') {
        destinationPage = TeacherDashboard(teacherId: userId);
      } else if (userType == 'Student') {
        destinationPage = StudentHomescreenPage(studentId: userId);
      } else {
        // Fallback for unknown type: Try default Student
        destinationPage = StudentHomescreenPage(studentId: userId);
      }

      log('WrapperScreen: Offline Route based on Hive ($userType)');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      }
      return;
    }

    // 2. Fallback: Only hit network if UserType is MISSING (rare edge case)
    await _fetchAndRouteFromFirebase(userId);
  }

  Future<void> _fetchAndRouteFromFirebase(String userId) async {
    // ... Legacy/Fallback logic (Only used if UserType was not saved properly)
    // Default to Students node search if we really don't know
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('Students/$userId');

    try {
      final snapshot = await databaseReference.get();

      if (snapshot.exists) {
        // Assume Student if found here
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => StudentHomescreenPage(studentId: userId)),
          );
        }
      } else {
        _handleError('User type not cached and user not found in Students.');
      }
    } catch (error) {
      _handleError('Error fetching user data: $error');
    }
  }

  void _handleError(String message) {
    log(message);
    if (mounted) {
      // Force logout, clear session data, and return to the main selection page
      _loginbox.put('isLoggedIn', false);
      _loginbox.delete('User');
      _loginbox.delete('UserType');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SelectionPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // --- Loading UI for the Wrapper Screen ---
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorPalette.accentBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: ColorPalette.secondary),
            SizedBox(height: 20),
            Text(
              'Preparing Dashboard...',
              style:
                  TextStyle(color: ColorPalette.secondary, fontFamily: 'Lato'),
            ),
          ],
        ),
      ),
    );
  }
}
