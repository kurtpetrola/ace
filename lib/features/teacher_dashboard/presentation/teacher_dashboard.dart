// lib/features/teacher_dashboard/presentation/teacher_dashboard.dart

import 'package:flutter/material.dart';

import 'package:ace/features/teacher_dashboard/presentation/teacher_classes_screen.dart';
import 'package:ace/features/teacher_dashboard/presentation/teacher_grades_screen.dart';
import 'package:ace/features/teacher_dashboard/presentation/teacher_account_screen.dart';

import 'package:ionicons/ionicons.dart';

class TeacherDashboard extends StatefulWidget {
  final String teacherId;

  const TeacherDashboard({super.key, required this.teacherId});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TeacherClassesScreen(teacherId: widget.teacherId),
      TeacherGradesScreen(teacherId: widget.teacherId),
      TeacherAccountScreen(teacherId: widget.teacherId),
    ];
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Teacher Dashboard';
      case 1:
        return 'Gradebook';
      case 2:
        return 'Account';
      default:
        return 'Teacher Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getTitle(_currentIndex),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.book_outline),
            activeIcon: Icon(Ionicons.book),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.stats_chart_outline),
            activeIcon: Icon(Ionicons.stats_chart),
            label: 'Grades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_outline),
            activeIcon: Icon(Ionicons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
