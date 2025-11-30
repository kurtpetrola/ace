// lib/features/student_dashboard/presentation/student_classroom_page.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/classroom/presentation/class_work_tab.dart';
import 'package:ace/features/classroom/presentation/people_tab.dart';
import 'package:ace/features/classroom/presentation/stream_tab.dart';

class StudentClassroomPage extends StatefulWidget {
  final String className;
  static const routeName = "ClassRoomPage";

  StudentClassroomPage(
      {required this.className, required AssetImage bannerImg});

  @override
  _StudentClassRoomPageState createState() => _StudentClassRoomPageState();
}

class _StudentClassRoomPageState extends State<StudentClassroomPage> {
  int pageIndex = 0;
  final pages = [
    Stream(),
    const Classwork(),
    const People(),
  ];

  @override
  Widget build(BuildContext context) {
    widget.className;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            color: ColorPalette.accentBlack,
          ),
        ),
        body: pages[pageIndex],
        bottomNavigationBar: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: ColorPalette.secondary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    pageIndex = 0;
                  });
                },
                icon: pageIndex == 0
                    ? const Icon(
                        Icons.stream,
                        color: Colors.black,
                        size: 35,
                      )
                    : const Icon(
                        Icons.stream_outlined,
                        color: Colors.black,
                        size: 35,
                      ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    pageIndex = 1;
                  });
                },
                icon: pageIndex == 1
                    ? const Icon(
                        Icons.article,
                        color: Colors.black,
                        size: 35,
                      )
                    : const Icon(
                        Icons.article_outlined,
                        color: Colors.black,
                        size: 35,
                      ),
              ),
              IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    pageIndex = 2;
                  });
                },
                icon: pageIndex == 2
                    ? const Icon(
                        Icons.people,
                        color: Colors.black,
                        size: 35,
                      )
                    : const Icon(
                        Icons.people_outline,
                        color: Colors.black,
                        size: 35,
                      ),
              ),
            ],
          ),
        ));
  }
}
