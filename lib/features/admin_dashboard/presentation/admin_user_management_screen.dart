// lib/features/admin_dashboard/presentation/admin_user_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ionicons/ionicons.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Example: Tab or segment control for different user groups
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All Users')),
              ButtonSegment(value: 'pending', label: Text('Pending Approval')),
            ],
            selected: const {'all'},
            onSelectionChanged: (Set<String> newSelection) {
              // TODO: Update a Riverpod state to filter the user list
            },
            selectedIcon: const Icon(Ionicons.checkmark_circle),
          ),
        ),
        // List of all users (Students and other Admins)
        Expanded(
          child: Center(
            child: Text(
              'List of all Student and Admin Accounts (Filter/Approve/Edit)',
              style: TextStyle(
                  color: ColorPalette.secondary.withOpacity(0.8), fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
