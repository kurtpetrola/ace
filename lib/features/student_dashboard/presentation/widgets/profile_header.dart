// lib/features/student_dashboard/presentation/widgets/profile_header.dart

import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String fullName;

  const ProfileHeader({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          elevation: 2,
          shape: const CircleBorder(),
          color: scheme.surface,
          child: CircleAvatar(
            radius: 70,
            backgroundColor: scheme.surface,
            child: Icon(
              Icons.person_outline_rounded,
              size: 80,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          fullName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onBackground,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Student',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
