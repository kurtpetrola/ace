// lib/features/shared/widget/personal_info_section.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/common/widgets/dialogs/alertdialog.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/shared/widget/profile_info_tile.dart';
import 'package:ace/features/shared/widget/account_stat_card.dart';
import 'package:ace/features/shared/widget/quick_action_button.dart';
import 'package:ionicons/ionicons.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'v1.0.0';
      });
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About ACE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Academia Classroom Explorer',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Version: $_appVersion'),
            const SizedBox(height: 16),
            Text(
              'Academia Classroom Explorer is an application designed to help students view, monitor, and manage their grades and educational information in a convenient, orderly, and efficient manner.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help? Contact us at:'),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Ionicons.mail_outline),
              title: const Text('support@ace.edu'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Ionicons.globe_outline),
              title: const Text('www.ace.edu/help'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Column(
              children: [
                // Gradient Header with Avatar (Black & White theme)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
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
                              const Color(0xFF3A3A3A),
                              const Color(0xFF2A2A2A),
                              const Color(0xFF1A1A1A),
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Column(
                      children: [
                        // Avatar with subtle glow effect
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: Colors.white,
                            child: Icon(
                              widget.avatarIcon,
                              size: 60,
                              color: ColorPalette.accentBlack,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.user.fullname,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.role,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [
                      // Statistics Cards (if provided) - Monochromatic grey colors
                      if (hasStats) ...[
                        Row(
                          children: [
                            if (widget.statValue1 != null)
                              Expanded(
                                child: AccountStatCard(
                                  icon:
                                      widget.statIcon1 ?? Ionicons.stats_chart,
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
                        const SizedBox(height: 24),
                      ],

                      // Quick Actions - Grey colors
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Quick Actions',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          QuickActionButton(
                            icon: Ionicons.settings_outline,
                            label: 'Settings',
                            onTap: _showSettingsDialog,
                            color: const Color(0xFF606060),
                          ),
                          QuickActionButton(
                            icon: Ionicons.help_circle_outline,
                            label: 'Help',
                            onTap: _showHelpDialog,
                            color: const Color(0xFF707070),
                          ),
                          QuickActionButton(
                            icon: Ionicons.information_circle_outline,
                            label: 'About',
                            onTap: _showAboutDialog,
                            color: const Color(0xFF505050),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Divider(color: scheme.outlineVariant),
                      const SizedBox(height: 20),

                      // Section Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Personal Information',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Responsive grid of info tiles
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double spacing = 12;
                          int crossAxisCount =
                              constraints.maxWidth > 700 ? 3 : 2;
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

                      // App Version Footer
                      if (_appVersion.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Divider(color: scheme.outlineVariant),
                        const SizedBox(height: 12),
                        Text(
                          'ACE $_appVersion',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top-right logout button
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              color: Colors.white.withOpacity(0.2),
              shape: const CircleBorder(),
              elevation: 4,
              child: IconButton(
                iconSize: 28,
                icon: const Icon(Ionicons.log_out_outline, color: Colors.white),
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
                            builder: (context) => const SelectionPage()),
                      );
                    }
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
