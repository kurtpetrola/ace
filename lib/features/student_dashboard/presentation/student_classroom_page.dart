// lib/features/student_dashboard/presentation/student_classroom_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/student_dashboard/presentation/tabs/stream_tab.dart';
import 'package:ace/features/student_dashboard/presentation/tabs/classwork_tab.dart';
import 'package:ace/features/student_dashboard/presentation/tabs/people_tab.dart';

class StudentClassroomPage extends StatefulWidget {
  final Classroom classroom;
  final String studentId;
  final int initialTab;

  const StudentClassroomPage({
    super.key,
    required this.classroom,
    required this.studentId,
    this.initialTab = 0,
  });

  @override
  State<StudentClassroomPage> createState() => _StudentClassroomPageState();
}

class _StudentClassroomPageState extends State<StudentClassroomPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              title: Text(
                widget.classroom.className,
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Ionicons.information_circle_outline,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    // show class details
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: ColorPalette.primary,
                unselectedLabelColor: Colors.grey.shade400,
                indicatorColor: ColorPalette.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Stream'),
                  Tab(text: 'Classwork'),
                  Tab(text: 'People'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            StreamTab(classroom: widget.classroom),
            ClassworkTab(
              classroom: widget.classroom,
              studentId: widget.studentId,
            ),
            PeopleTab(classroom: widget.classroom),
          ],
        ),
      ),
    );
  }
}
