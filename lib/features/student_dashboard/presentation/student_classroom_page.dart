// lib/features/student_dashboard/presentation/student_classroom_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/student_dashboard/presentation/tabs/stream_tab.dart';
import 'package:ace/features/student_dashboard/presentation/tabs/classwork_tab.dart';
import 'package:ace/features/student_dashboard/presentation/tabs/people_tab.dart';

class StudentClassroomPage extends StatelessWidget {
  final Classroom classroom;

  const StudentClassroomPage({super.key, required this.classroom});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // Custom AppBar with Banner and Class Info
              SliverAppBar(
                backgroundColor: ColorPalette.accentBlack,
                expandedHeight: 250.0,
                pinned: true,
                floating: false,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 16.0, bottom: 65.0),
                  title: Text(
                    classroom.className,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Class Banner Image
                      Image.asset(
                        classroom.bannerImgPath,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.4),
                        colorBlendMode: BlendMode.darken,
                      ),
                      // Class Description and Creator Overlay
                      Positioned(
                        bottom: 80,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classroom.description,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created by: ${classroom.creator}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab Bar is placed at the bottom of the AppBar
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: [
                    Tab(
                      icon: Icon(Ionicons.chatbubble_ellipses_outline),
                      text: 'Stream',
                    ),
                    Tab(
                      icon: Icon(Ionicons.folder_open_outline),
                      text: 'Classwork',
                    ),
                    Tab(
                      icon: Icon(Ionicons.people_outline),
                      text: 'People',
                    ),
                  ],
                ),
              ),
            ];
          },
          // Tab Bar Views
          body: TabBarView(
            children: [
              StreamTab(classroom: classroom),
              ClassworkTab(classroom: classroom),
              PeopleTab(classroom: classroom),
            ],
          ),
        ),
      ),
    );
  }
}
