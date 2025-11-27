// lib/features/admin_dashboard/presentation/admin_homescreen_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_class_management_screen.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_user_management_screen.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_grades_management_screen.dart';
import 'package:ace/features/dashboard/presentation/account_screen.dart';

class AdminHomeScreenPage extends StatefulWidget {
  const AdminHomeScreenPage({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreenPage> createState() => _AdminHomeScreenPageState();
}

class _AdminHomeScreenPageState extends State<AdminHomeScreenPage> {
  int pageIndex = 0;

  // Define the admin management screens
  final pages = [
    const AdminClassManagementScreen(), // Manage Classes (Create/Edit)
    const AdminGradesManagementScreen(), // Manage Grades (View/Update)
    const AdminUserManagementScreen(), // Manage Users (Approve/Block)
    const Account(), // Reusing the account screen for profile/logout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: Admin dashboard might use a different primary background color
      backgroundColor: ColorPalette.accentBlack,

      appBar: AppBar(
        title: Text(
          _getPageTitle(pageIndex),
          style: const TextStyle(
              color: ColorPalette.secondary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorPalette.accentBlack,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: pages[pageIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        backgroundColor: ColorPalette.secondary,
        selectedItemColor:
            ColorPalette.accentBlack, // Highlighted tab uses the primary color
        unselectedItemColor: ColorPalette.accentBlack.withOpacity(0.6),
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 26),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.school_outline),
            activeIcon: Icon(Ionicons.school),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.ribbon_outline),
            activeIcon: Icon(Ionicons.ribbon),
            label: 'Grades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.people_circle_outline),
            activeIcon: Icon(Ionicons.people_circle),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_outline),
            activeIcon: Icon(Ionicons.person),
            label: 'Account',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Class Management';
      case 1:
        return 'Grade Oversight';
      case 2:
        return 'User Management';
      case 3:
        return 'Admin Account';
      default:
        return 'Admin Dashboard';
    }
  }
}
