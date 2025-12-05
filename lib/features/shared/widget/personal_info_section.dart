// lib/features/shared/widget/personal_info_section.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'package:ace/common/widgets/dialogs/alertdialog.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/shared/widget/profile_info_tile.dart';

class PersonalInfoSection extends StatelessWidget {
  final User user;
  final String role;
  final IconData avatarIcon;
  final bool isAdmin;

  const PersonalInfoSection({
    super.key,
    required this.user,
    this.role = "Student",
    this.avatarIcon = Icons.person_outline_rounded,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final _loginbox = Hive.box("_loginbox");

    final infoList = [
      {
        'label': isAdmin ? 'Admin ID' : 'Student ID',
        'value': user.userId.toString()
      },
      {'label': 'Gender', 'value': user.gender.toString()},
      {'label': 'Age', 'value': user.age.toString()},
      {'label': 'E-mail', 'value': user.email.toString()},
      {
        'label': 'Department',
        'value': user.department.toString(),
        'fullWidth': true
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        children: [
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: scheme.surfaceVariant,
                    child: Icon(
                      avatarIcon,
                      size: 56,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.fullname,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    role,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: scheme.outlineVariant),
                  const SizedBox(height: 20),

                  // Section Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Responsive grid of info tiles
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double spacing = 12;
                      int crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
                      double width = (constraints.maxWidth -
                              spacing * (crossAxisCount - 1)) /
                          crossAxisCount;
                      double height = 90;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: infoList.map((item) {
                          bool fullWidth = item['fullWidth'] == true;
                          double tileWidth =
                              fullWidth ? constraints.maxWidth : width;

                          return SizedBox(
                            width: tileWidth,
                            height: height,
                            child: ProfileInfoTile(
                              label: item['label'] as String,
                              value: item['value'] as String,
                              minHeight: height,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Top-right logout button
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                iconSize: 32,
                icon: Icon(Icons.exit_to_app, color: scheme.primary),
                onPressed: () async {
                  final action = await AlertDialogs.yesCancelDialog(
                    context,
                    'Logout this account?',
                    'You can always come back any time.',
                  );
                  if (action == DialogsAction.yes) {
                    _loginbox.put("isLoggedIn", false);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const SelectionPage()),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
