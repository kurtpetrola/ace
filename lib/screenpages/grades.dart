import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ace/constant/colors.dart';

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

class Grades extends StatelessWidget {
  const Grades({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GradesModel(),
      child: GradesView(),
    );
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
                child: Column(
                  children: [
                    HeaderRow(),
                    SizedBox(height: 20),
                    SubjectList(),
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

class HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Subject Code',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 1,
            child: GradeTypeSelector(),
          ),
        ],
      ),
    );
  }
}

class GradeTypeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GradesModel>(context);
    return DropdownButton<String>(
      value: model.selectedGradeType,
      items: model.gradeTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) => model.updateSelectedGradeType(value!),
    );
  }
}

class SubjectList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GradesModel>(context);
    return Table(
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: model.subjects.asMap().entries.map((entry) {
        final index = entry.key;
        final subject = entry.value;
        return TableRow(
          children: [
            TableCell(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(subject.code),
              ),
            ),
            TableCell(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TextFormField(
                  initialValue: subject.grade,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && int.tryParse(value) != null) {
                      model.updateGrade(index, value);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
