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

      // Fetch grades using new keys, falling back to old ones if necessary
      final prelim = gradeDetails['Prelim'] ?? gradeDetails['P1'] ?? '-';
      final midterm = gradeDetails['Midterm'] ?? gradeDetails['P2'] ?? '-';
      final finalTerm = gradeDetails['Final'] ?? gradeDetails['P3'] ?? '-';

      // The calculated average or final grade
      final average = gradeDetails['Average'] ?? '-';

      return DataRow(
        cells: [
          DataCell(Text(subjectCode,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color))),
          // Display the calculated Average prominently
          DataCell(Text(average,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color))),
          DataCell(Text(prelim,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color))),
          DataCell(Text(midterm,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color))),
          DataCell(Text(finalTerm,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color))),
        ],
      );
    }).toList();

    return Container(
      width: double.infinity, // Occupy full width
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
            color:
                Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
      ),
      padding:
          const EdgeInsets.all(0), // Removed inner padding for cleaner look
      child: ClipRRect(
        // Clip content to border radius
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(ColorPalette.primary
                  .withOpacity(0.9)), // Use WidgetStateProperty
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato', // Consistent font
              ),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  // Alternating row colors could be added here if passed index
                  return ColorPalette.lighterRed.withOpacity(0.2);
                },
              ),
              columns: const [
                DataColumn(label: Text('Course')),
                DataColumn(label: Text('Average')),
                DataColumn(label: Text('Prelim')),
                DataColumn(label: Text('Midterm')),
                DataColumn(label: Text('Final')),
              ],
              rows: rows,
              columnSpacing: 20,
              horizontalMargin: 20,
              headingRowHeight: 50,
              dataRowMinHeight: 45,
              dataRowMaxHeight: 45,
            ),
          ),
        ),
      ),
    );
  }
}
