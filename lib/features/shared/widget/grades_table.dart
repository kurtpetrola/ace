// lib/features/shared/widget/grades_table.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';

class GradeTable extends StatelessWidget {
  final Map<String, dynamic> grades;

  const GradeTable({super.key, required this.grades});

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const Center(
        child:
            Text('No grades to display', style: TextStyle(color: Colors.white)),
      );
    }

    final rows = grades.entries.map((entry) {
      final subjectCode = entry.key;
      final gradeDetails = Map<String, dynamic>.from(entry.value as Map);

      final finalGrade = gradeDetails['Final'] ?? gradeDetails['P3'] ?? '-';

      return DataRow(
        cells: [
          DataCell(Text(subjectCode,
              style: const TextStyle(color: ColorPalette.accentBlack))),
          DataCell(Text(finalGrade,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.accentBlack))),
          DataCell(Text(gradeDetails['P1'] ?? '-',
              style: const TextStyle(color: ColorPalette.accentBlack))),
          DataCell(Text(gradeDetails['P2'] ?? '-',
              style: const TextStyle(color: ColorPalette.accentBlack))),
          DataCell(Text(gradeDetails['P3'] ?? '-',
              style: const TextStyle(color: ColorPalette.accentBlack))),
        ],
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Table background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              MaterialStateProperty.all(ColorPalette.primary.withOpacity(0.8)),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          dataRowColor: MaterialStateProperty.all(
              ColorPalette.lighterRed.withOpacity(0.2)),
          columns: const [
            DataColumn(label: Text('Course Code')),
            DataColumn(label: Text('FINAL')),
            DataColumn(label: Text('P1')),
            DataColumn(label: Text('P2')),
            DataColumn(label: Text('P3')),
          ],
          rows: rows,
          columnSpacing: 24,
          horizontalMargin: 12,
        ),
      ),
    );
  }
}
