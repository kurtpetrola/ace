// lib/features/admin_dashboard/presentation/admin_account_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'dart:convert';
import 'package:ace/features/shared/widget/personal_info_section.dart';

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
      body: FutureBuilder<User>(
        future: getAdminUser(),
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
                PersonalInfoSection(
                  user: user,
                  role: "Administrator",
                  avatarIcon: Icons.admin_panel_settings_outlined,
                  isAdmin: true,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Refactored getAdminUser function: Returns a single Future<User>
  Future<User> getAdminUser() async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("Admins/$adminId");
    try {
      DataSnapshot snapshot = await databaseReference.get();
      if (snapshot.exists && snapshot.value != null) {
        // This relies on the Admin data structure matching the 'User' model
        Map<String, dynamic> myObj = jsonDecode(jsonEncode(snapshot.value));
        User myUserObj = User.fromJson(myObj);
        return myUserObj;
      } else {
        throw Exception("Admin data not found for $adminId.");
      }
    } catch (error) {
      rethrow;
    }
  }
}
