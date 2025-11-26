import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/features/dashboard/presentation/account_screen.dart';
import 'package:ace/features/dashboard/presentation/classroom_screen.dart';
import 'package:ace/features/dashboard/presentation/grades_screen.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  int pageIndex = 0;
  final pages = [
    Classroom(),
    GradesView(),
    Account(),
  ];

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
