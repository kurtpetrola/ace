// lib/features/shared/widget/personal_info_section.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/common/widgets/dialogs/alertdialog.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/shared/widget/profile_info_tile.dart';
import 'package:ace/features/shared/widget/account_stat_card.dart';
import 'package:ionicons/ionicons.dart';

class PersonalInfoSection extends StatefulWidget {
  final User user;
  final String role;
  final IconData avatarIcon;
  final bool isAdmin;
  final int? statValue1;
  final String? statLabel1;
  final IconData? statIcon1;
  final int? statValue2;
  final String? statLabel2;
  final IconData? statIcon2;

  const PersonalInfoSection({
    super.key,
    required this.user,
    this.role = "Student",
    this.avatarIcon = Icons.person_outline_rounded,
    this.isAdmin = false,
    this.statValue1,
    this.statLabel1,
    this.statIcon1,
    this.statValue2,
    this.statLabel2,
    this.statIcon2,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final _loginbox = Hive.box("_loginbox");

    final infoList = [
      {
        'label': widget.isAdmin ? 'Admin ID' : 'Student ID',
        'value': widget.user.userId.toString()
      },
      {'label': 'Gender', 'value': widget.user.gender.toString()},
      {'label': 'Age', 'value': widget.user.age.toString()},
      {'label': 'E-mail', 'value': widget.user.email.toString()},
      {
        'label': 'Department',
        'value': widget.user.department.toString(),
        'fullWidth': true
      },
    ];

    final hasStats = widget.statValue1 != null || widget.statValue2 != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          // Main Profile Card
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with Avatar and Role
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isAdmin
                          ? [
                              const Color(0xFF2D2D2D),
                              const Color(0xFF1A1A1A),
                              const Color(0xFF0D0D0D),
                            ]
                          : [
                              ColorPalette.primary, // #D31144
                              const Color(0xFFA30D35), // Darker shade
                              const Color(0xFF76001F), // Accent Dark Red
                            ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Avatar
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: isDark
                                    ? ColorPalette.accentBlack
                                    : Colors.white,
                                child: Icon(
                                  widget.avatarIcon,
                                  size: 48,
                                  color: isDark
                                      ? Colors.white
                                      : ColorPalette.accentBlack,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Name
                            Text(
                              widget.user.fullname,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.role.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Logout Button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(Ionicons.log_out_outline,
                              color: Colors.white),
                          onPressed: () async {
                            final action = await AlertDialogs.yesCancelDialog(
                              context,
                              'Logout this account?',
                              'You can always come back any time.',
                            );
                            if (action == DialogsAction.yes) {
                              _loginbox.put("isLoggedIn", false);
                              if (context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectionPage()),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Statistics Section
                if (hasStats)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (widget.statValue1 != null)
                          Expanded(
                            child: AccountStatCard(
                              icon: widget.statIcon1 ?? Ionicons.stats_chart,
                              label: widget.statLabel1 ?? 'Stat 1',
                              value: widget.statValue1.toString(),
                              color: widget.isAdmin
                                  ? const Color(0xFF505050)
                                  : const Color(0xFF606060),
                            ),
                          ),
                        if (widget.statValue1 != null &&
                            widget.statValue2 != null)
                          const SizedBox(width: 12),
                        if (widget.statValue2 != null)
                          Expanded(
                            child: AccountStatCard(
                              icon: widget.statIcon2 ?? Ionicons.briefcase,
                              label: widget.statLabel2 ?? 'Stat 2',
                              value: widget.statValue2.toString(),
                              color: widget.isAdmin
                                  ? const Color(0xFF404040)
                                  : const Color(0xFF707070),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Personal Information Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Personal Information',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Adaptive grid layout
                          int crossAxisCount =
                              constraints.maxWidth > 600 ? 3 : 2;
                          double spacing = 12;
                          double itemWidth = (constraints.maxWidth -
                                  (spacing * (crossAxisCount - 1))) /
                              crossAxisCount;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: infoList.map((item) {
                              bool fullWidth = item['fullWidth'] == true;

                              return SizedBox(
                                width: fullWidth
                                    ? constraints.maxWidth
                                    : itemWidth,
                                child: ProfileInfoTile(
                                  label: item['label'] as String,
                                  value: item['value'] as String,
                                  minHeight: 85,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
