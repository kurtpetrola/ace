// lib/features/auth/wrapper_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:ace/models/user.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/dashboard/presentation/homescreen_page.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_homescreen_page.dart';

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
    // Start the routing process immediately when the screen loads
    _navigateToDashboard();
  }

  // --- Core Routing Logic ---
  Future<void> _navigateToDashboard() async {
    final fullname = _loginbox.get("User"); // Get the user key from Hive

    try {
      // 1. Fetch user data from Firebase
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref().child("Students/$fullname");

      final snapshot = await databaseReference.get();

      if (snapshot.exists && snapshot.value != null) {
        // Decode and map the data to your updated User model
        Map<String, dynamic> myObj = jsonDecode(jsonEncode(snapshot.value));
        User user = User.fromJson(myObj);

        // 2. Check the user's role for routing
        Widget destinationPage;

        if (user.role == 'admin') {
          // Navigate to Admin Dashboard
          destinationPage = const AdminHomeScreenPage();
        } else {
          // Default: Navigate to Student Dashboard
          destinationPage = const HomeScreenPage();
        }

        // 3. Perform the navigation
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      } else {
        // Handle case where user data doesn't exist (e.g., force logout)
        _handleError('User data not found.');
      }
    } catch (error) {
      // Handle Firebase/Network errors
      _handleError('Error fetching user data: $error');
    }
  }

  void _handleError(String message) {
    // In a real app, you would show an error message, toast, or navigate back to login
    print(message);
    if (mounted) {
      // For simplicity, navigate to the student home page on error,
      // but a proper implementation might route to a login or error page.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreenPage()),
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
