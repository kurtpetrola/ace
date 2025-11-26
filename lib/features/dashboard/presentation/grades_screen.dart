import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';

class Subject {
  final String code;
  String grade;

  Subject({required this.code, required this.grade});
}

class GradesModel extends ChangeNotifier {
  List<Subject> subjects = [
    Subject(code: 'ITE 115', grade: '95'),
    Subject(code: 'ITE 300', grade: '95'),
    Subject(code: 'ITE 302', grade: '95'),
    Subject(code: 'ITE 298', grade: '95'),
    Subject(code: 'ITE 304', grade: '95'),
    Subject(code: 'ITE 303', grade: '95'),
    Subject(code: 'ITE 031', grade: '95'),
  ];

  List<String> gradeTypes = ['P1', 'P2', 'P3'];
  String selectedGradeType = 'P1';

  void updateGrade(int index, String newGrade) {
    subjects[index].grade = newGrade;
    notifyListeners();
  }

  void updateSelectedGradeType(String newType) {
    selectedGradeType = newType;
    notifyListeners();
  }
}

class GradesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.accentBlack,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                width: constraints.maxWidth > 600
                    ? 600
                    : constraints.maxWidth * 0.9,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
