// lib/features/admin_dashboard/presentation/admin_class_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ionicons/ionicons.dart';

class AdminClassManagementScreen extends StatelessWidget {
  const AdminClassManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Button to create a new class
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to a form to create a new class
            },
            icon: const Icon(Ionicons.add_circle, color: Colors.white),
            label: const Text('Create New Class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.secondary,
              foregroundColor: ColorPalette.accentBlack,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        // List of all classes (similar to your student classroom_screen)
        Expanded(
          child: Center(
            child: Text(
              'List of All Classes (Click to Edit)',
              style: TextStyle(
                  color: ColorPalette.secondary.withOpacity(0.8), fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
