// lib/features/admin_dashboard/presentation/admin_user_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/models/user.dart';
import 'package:ace/services/user_service.dart';
import 'package:ace/features/admin_dashboard/presentation/widgets/edit_user_dialog.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final UserService _userService = UserService();
  Future<List<User>>? _studentsFuture;
  Set<String> _selectedSegment = {'students'};
  final TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUserList();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchUserList() {
    setState(() {
      if (_selectedSegment.contains('students')) {
        _studentsFuture = _userService.fetchAllStudents();
      } else {
        _studentsFuture = _userService.fetchAllAdmins();
      }
    });

    // Update the local lists when the future completes
    _studentsFuture?.then((users) {
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
          _filterUsers(); // Re-apply search filter
        });
      }
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user.fullname.toLowerCase().contains(query) ||
            user.userId.toLowerCase().contains(query) ||
            user.department.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Function to show the Firebase Console instruction message
  void _showConsoleMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'User editing and password reset are managed via the Firebase Console.'),
        backgroundColor: ColorPalette.secondary,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header & Search
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Segmented Control
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'students',
                      label: Text('Students'),
                      icon: Icon(Icons.school)),
                  ButtonSegment(
                      value: 'admins',
                      label: Text('Admins'),
                      icon: Icon(Icons.admin_panel_settings)),
                ],
                selected: _selectedSegment,
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedSegment = newSelection;
                    _searchController.clear(); // Clear search on switch
                    _fetchUserList();
                  });
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return ColorPalette.secondary.withOpacity(0.2);
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return ColorPalette.accentBlack;
                    }
                    return Colors.grey;
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Name, ID, or Dept...',
                  prefixIcon: const Icon(Ionicons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List of users
        Expanded(
          child: FutureBuilder<List<User>>(
            future: _studentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading users: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Use _filteredUsers instead of snapshot data directly
              // If _filteredUsers is empty but snapshot has data, it means search found nothing.
              // If snapshot is empty, it means no users at all.
              final displayList = _filteredUsers;

              if (displayList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'No users found matching "${_searchController.text}"'
                            : 'No users found.',
                        style: TextStyle(
                            color: ColorPalette.secondary.withOpacity(0.8),
                            fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final user = displayList[index];
                  final isStudent = user.role != 'admin';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isStudent
                                  ? ColorPalette.primary.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isStudent
                                  ? Icons.school
                                  : Icons.admin_panel_settings,
                              color: isStudent
                                  ? ColorPalette.primary
                                  : Colors.blue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullname.isNotEmpty
                                      ? user.fullname
                                      : 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: ColorPalette.accentBlack,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildBadge(
                                        user.userId,
                                        Colors.grey.shade200,
                                        Colors.grey.shade700),
                                    if (isStudent)
                                      _buildBadge(user.department,
                                          Colors.orange.shade50, Colors.orange),
                                    if (!isStudent)
                                      _buildBadge('Admin', Colors.blue.shade50,
                                          Colors.blue),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Actions
                          PopupMenuButton<String>(
                            icon:
                                const Icon(Icons.more_vert, color: Colors.grey),
                            onSelected: (value) {
                              if (value == 'edit') {
                                showDialog(
                                  context: context,
                                  builder: (_) => EditUserDialog(
                                    user: user,
                                    onUserUpdated: _fetchUserList,
                                  ),
                                );
                              } else if (value == 'reset_password') {
                                _showConsoleMessage(context);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 10),
                                    Text('Edit Profile'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'reset_password',
                                child: Row(
                                  children: [
                                    Icon(Ionicons.key, size: 20),
                                    SizedBox(width: 10),
                                    Text('Reset Password'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
