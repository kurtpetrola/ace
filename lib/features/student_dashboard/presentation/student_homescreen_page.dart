// lib/features/student_dashboard/presentation/student_homescreen_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/features/student_dashboard/presentation/student_account_screen.dart';
import 'package:ace/features/student_dashboard/presentation/student_classroom_screen.dart';
import 'package:ace/features/student_dashboard/presentation/student_grades_screen.dart';
import 'package:ace/features/student_dashboard/presentation/widgets/notification_badge.dart';
import 'package:ace/features/student_dashboard/presentation/student_notifications_screen.dart';
import 'package:ace/services/fcm_service.dart';

class StudentHomescreenPage extends StatefulWidget {
  // 1. Add required studentId to the StatefulWidget
  final String studentId;
  const StudentHomescreenPage({Key? key, required this.studentId})
      : super(key: key);

  @override
  State<StudentHomescreenPage> createState() => _StudentHomeScreenPageState();
}

class _StudentHomeScreenPageState extends State<StudentHomescreenPage> {
  int pageIndex = 0;

  // The pages list will now be initialized in initState or lazy-loaded,
  // since it depends on widget.studentId
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // 2. Initialize the pages list, passing the studentId to GradesView
    pages = [
      StudentClassroomScreen(),
      GradesView(studentId: widget.studentId), // Pass the ID here
      StudentAccountScreen(),
    ];

    // 3. Initialize FCM for push notifications
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      await FCMService().initialize(widget.studentId);
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getPageTitle(pageIndex),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          NotificationBadge(
            studentId: widget.studentId,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StudentNotificationsScreen(
                    studentId: widget.studentId,
                  ),
                ),
              );
            },
          ),
        ],
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

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Student Classes';
      case 1:
        return 'Grades Overview';
      case 2:
        return 'Account Settings';
      default:
        return 'Student Dashboard';
    }
  }
}
