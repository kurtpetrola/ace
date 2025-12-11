// lib/features/student_dashboard/presentation/student_account_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:hive/hive.dart';
import 'package:ace/models/user.dart';
import 'package:ace/features/shared/widget/personal_info_section.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/features/auth/services/student_auth_service.dart';
import 'package:ace/core/theme/theme_provider.dart';

class StudentAccountScreen extends ConsumerStatefulWidget {
  const StudentAccountScreen({super.key});

  @override
  ConsumerState<StudentAccountScreen> createState() =>
      _StudentAccountScreenState();
}

class _StudentAccountScreenState extends ConsumerState<StudentAccountScreen> {
  final _loginbox = Hive.box("_loginbox");
  late String studentId;
  late Stream<Map<String, dynamic>> _userStatsStream;
  final StudentAuthService _authService = StudentAuthService();

  @override
  void initState() {
    super.initState();
    studentId = _loginbox.get("User") ?? "";
    _userStatsStream = _authService.streamUserStatsCached(studentId);
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to respect status bar
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _userStatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            print('[ERROR] UI Error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Something went wrong",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Can't load profile stats.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _userStatsStream =
                          _authService.streamUserStatsCached(studentId);
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final user = data['user'] as User;
          final enrolledClassesCount = data['enrolledClasses'] as int;
          final pendingAssignments = data['pendingAssignments'] as int;

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: topPadding, bottom: 60),
            child: Column(
              children: [
                PersonalInfoSection(
                  user: user,
                  role: "Student",
                  avatarIcon: Icons.school_outlined,
                  isAdmin: false,
                  statValue1: enrolledClassesCount,
                  statLabel1: 'Enrolled Classes',
                  statIcon1: Ionicons.book_outline,
                  statValue2: pendingAssignments,
                  statLabel2: 'Pending Work',
                  statIcon2: Ionicons.time_outline,
                ),
                const SizedBox(height: 16),
                _buildDarkModeToggle(context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build dark mode toggle widget
  Widget _buildDarkModeToggle(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDarkMode ? Ionicons.moon : Ionicons.sunny,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDarkMode ? 'Enabled' : 'Disabled',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isDarkMode,
            onChanged: (_) => themeNotifier.toggleTheme(),
            activeColor: ColorPalette.primary,
          ),
        ],
      ),
    );
  }
}
