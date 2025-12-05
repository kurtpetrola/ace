// lib/features/student_dashboard/presentation/student_account_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:ace/models/user.dart';
import 'package:ace/features/student_dashboard/presentation/widgets/personal_info_section.dart';

class StudentAccountScreen extends StatefulWidget {
  const StudentAccountScreen({super.key});

  @override
  State<StudentAccountScreen> createState() => _StudentAccountScreenState();
}

class _StudentAccountScreenState extends State<StudentAccountScreen> {
  final _loginbox = Hive.box("_loginbox");
  late var fullname = _loginbox.get("User");

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
      body: FutureBuilder<User>(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded),
                  SizedBox(height: 8),
                  Text("Something went wrong"),
                  SizedBox(height: 4),
                  Text("Please try again."),
                ],
              ),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: topPadding, bottom: 24),
            child: Column(
              children: [
                // Personal info card with logout button
                PersonalInfoSection(user: user),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fetch single user from Firebase
  Future<User> getUser() async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("Students/$fullname");
    try {
      DataSnapshot snapshot = await databaseReference.get();
      if (snapshot.exists && snapshot.value != null) {
        Map<String, dynamic> myObj = jsonDecode(jsonEncode(snapshot.value));
        User myUserObj = User.fromJson(myObj);
        return myUserObj;
      } else {
        throw Exception("Student data not found for $fullname.");
      }
    } catch (error) {
      rethrow;
    }
  }
}
