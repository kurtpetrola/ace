// lib/features/auth/wrapper_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:ace/models/user.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/student_dashboard/presentation/student_homescreen_page.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_homescreen_page.dart';
// Note: HomeScreenPage must now accept a 'studentId' argument.

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  final _loginbox = Hive.box("_loginbox");

  @override
  void initState() {
    super.initState();
    _navigateToDashboard();
  }

  // --- Core Routing Logic ---
  Future<void> _navigateToDashboard() async {
    final userId =
        _loginbox.get("User"); // Get the user key (studentId or adminId)
    final userType = _loginbox
        .get("UserType"); // Get the type (e.g., "Admin", "Student", or null)

    // Log the user context for debugging
    print(
        'WrapperScreen: Attempting to navigate for User ID: $userId, Type: $userType');

    // 1. Determine the correct Firebase path (Admins/ or Students/)
    String firebaseNode;
    if (userType == "Admin") {
      firebaseNode = "Admins"; // Use the Admins node for admins
    } else {
      // Default to Students node if type is null or anything else (e.g., 'Student')
      firebaseNode = "Students";
    }

    // Guard clause: ensure we have a user ID to fetch data
    if (userId == null || userId.isEmpty) {
      return _handleError('User ID not found in Hive. Forced logout.');
    }

    // Construct the full database path
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("$firebaseNode/$userId");

    try {
      final snapshot = await databaseReference.get();

      if (snapshot.exists && snapshot.value != null) {
        // Decode and map the data
        Map<String, dynamic> myObj = jsonDecode(jsonEncode(snapshot.value));
        User user =
            User.fromJson(myObj); // Assumes User model has a 'role' field

        // 2. Check the user's role for routing
        Widget destinationPage;
        // Ensure the role is checked safely
        final role = user.role;

        // --- REVERTED: Now strictly checking for 'admin' (case-sensitive) ---
        print('WrapperScreen: Fetched role from DB: $role');

        if (role == 'admin') {
          // Navigate to Admin Dashboard
          destinationPage = const AdminHomeScreenPage();
          print('WrapperScreen: Redirecting to Admin Dashboard.');
        } else {
          // Default: Navigate to Student Dashboard
          // We now pass the userId to the HomeScreenPage for Riverpod consumption.
          destinationPage = StudentHomescreenPage(studentId: userId);
          print(
              'WrapperScreen: Redirecting to Student Dashboard (Role was: $role).');
        }

        // 3. Perform the navigation
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      } else {
        // Handle case where user data doesn't exist (e.g., force logout)
        _handleError('User data not found at $firebaseNode/$userId.');
      }
    } catch (error) {
      // Handle Firebase/Network errors
      _handleError('Error fetching user data for routing: $error');
    }
  }

  void _handleError(String message) {
    print(message);
    if (mounted) {
      // Force logout, clear session data, and return to the main selection page
      _loginbox.put("isLoggedIn", false);
      _loginbox.delete("User");
      _loginbox.delete("UserType");
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
              "Preparing Dashboard...",
              style:
                  TextStyle(color: ColorPalette.secondary, fontFamily: 'Lato'),
            ),
          ],
        ),
      ),
    );
  }
}
