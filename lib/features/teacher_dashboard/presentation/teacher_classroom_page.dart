// lib/features/teacher_dashboard/presentation/teacher_classroom_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/services/class_service.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/features/student_dashboard/presentation/tabs/stream_tab.dart'; // Reusing StreamTab
import 'package:ace/features/teacher_dashboard/presentation/tabs/teacher_classwork_tab.dart';
import 'package:ace/features/teacher_dashboard/presentation/tabs/teacher_people_tab.dart';

class TeacherClassroomPage extends StatefulWidget {
  final Classroom classroom;
  final String teacherId;
  final int initialTab;

  const TeacherClassroomPage({
    super.key,
    required this.classroom,
    required this.teacherId,
    this.initialTab = 0,
  });

  @override
  State<TeacherClassroomPage> createState() => _TeacherClassroomPageState();
}

class _TeacherClassroomPageState extends State<TeacherClassroomPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ClassService _classService = ClassService();

  Future<void> _deleteClass() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class?'),
        content: Text(
          'Are you sure you want to delete "${widget.classroom.className}"?\n\n'
          '⚠️ This will UNENROLL all students and DELETE all classwork/assignments. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _classService.deleteClass(widget.classroom.classId);
      if (mounted) {
        Navigator.pop(context); // Go back to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${widget.classroom.className}')),
        );
      }
    }
  }

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
                style: Theme.of(context).appBarTheme.titleTextStyle,
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
                PopupMenuButton<String>(
                  icon: Icon(Ionicons.settings_outline,
                      color: Theme.of(context).iconTheme.color),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteClass();
                    }
                  },
                  itemBuilder: (context) => [
                    // Can add 'Edit' here later
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Ionicons.trash_outline,
                              color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete Class',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).tabBarTheme.labelColor ??
                    Theme.of(context).colorScheme.primary,
                unselectedLabelColor:
                    Theme.of(context).tabBarTheme.unselectedLabelColor ??
                        Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).tabBarTheme.indicatorColor ??
                    Theme.of(context).colorScheme.primary,
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
            // Reusing StreamTab - assuming the teacher can post, which StreamTab supports if logged in
            StreamTab(classroom: widget.classroom),

            // New Teacher Classwork Tab
            TeacherClassworkTab(
              classroom: widget.classroom,
              teacherId: widget.teacherId,
            ),

            // New Teacher People Tab
            TeacherPeopleTab(classroom: widget.classroom),
          ],
        ),
      ),
    );
  }
}
