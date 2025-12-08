// lib/features/admin_dashboard/presentation/admin_homescreen_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_class_management_screen.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_user_management_screen.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_grades_management_screen.dart';
import 'package:ace/features/admin_dashboard/presentation/admin_account_screen.dart';

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
    const AdminAccount(), // Admin Account Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: Admin dashboard might use a different primary background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          _getPageTitle(pageIndex),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        selectedIconTheme:
            Theme.of(context).bottomNavigationBarTheme.selectedIconTheme,
        unselectedIconTheme:
            Theme.of(context).bottomNavigationBarTheme.unselectedIconTheme,
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
