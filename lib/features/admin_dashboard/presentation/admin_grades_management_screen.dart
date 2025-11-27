// lib/features/admin_dashboard/presentation/admin_grades_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';

class AdminGradesManagementScreen extends StatelessWidget {
  const AdminGradesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Admin Grade Oversight',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorPalette.secondary),
          ),
          const SizedBox(height: 20),
          // Placeholder for searching/filtering students or classes
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const TextField(
              decoration: InputDecoration(
                labelText: 'Search Student ID or Class Code',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'List of Students/Classes with Grade Edit buttons will go here.',
            style: TextStyle(color: ColorPalette.secondary.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
