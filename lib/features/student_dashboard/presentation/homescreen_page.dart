// lib/features/student_dashboard/presentation/homescreen_page.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/features/student_dashboard/presentation/account_screen.dart';
import 'package:ace/features/student_dashboard/presentation/classroom_screen.dart';
import 'package:ace/features/student_dashboard/presentation/grades_screen.dart';

class HomeScreenPage extends StatefulWidget {
  // 1. Add required studentId to the StatefulWidget
  final String studentId;
  const HomeScreenPage({Key? key, required this.studentId}) : super(key: key);

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  int pageIndex = 0;

  // The pages list will now be initialized in initState or lazy-loaded,
  // since it depends on widget.studentId
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // 2. Initialize the pages list, passing the studentId to GradesView
    pages = [
      ClassroomScreen(),
      GradesView(studentId: widget.studentId), // Pass the ID here
      AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.accentBlack,
      body: pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        backgroundColor: ColorPalette.secondary,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(0.6),
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 26),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.book_outline),
            activeIcon: Icon(Ionicons.book),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.sparkles_outline),
            activeIcon: Icon(Ionicons.sparkles),
            label: 'Grades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_outline),
            activeIcon: Icon(Ionicons.person),
            label: 'Account',
          ),
        ],
        elevation: 8, // Adds material elevation for depth
        type: BottomNavigationBarType.fixed, // Ensures labels are always shown
      ),
    );
  }
}
