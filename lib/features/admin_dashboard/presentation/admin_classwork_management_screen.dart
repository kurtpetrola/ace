// lib/features/admin_dashboard/presentation/admin_classwork_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/services/classwork_service.dart';
import 'package:ace/services/submission_service.dart';
import 'package:ace/features/admin_dashboard/presentation/create_classwork_dialog.dart';
import 'package:ace/features/admin_dashboard/presentation/submissions_detail_dialog.dart';

class AdminClassworkManagementScreen extends StatefulWidget {
  final Classroom classroom;
  final String adminId;

  const AdminClassworkManagementScreen({
    super.key,
    required this.classroom,
    required this.adminId,
  });

  @override
  State<AdminClassworkManagementScreen> createState() =>
      _AdminClassworkManagementScreenState();
}

class _AdminClassworkManagementScreenState
    extends State<AdminClassworkManagementScreen>
    with SingleTickerProviderStateMixin {
  final ClassworkService _service = ClassworkService();
  final SubmissionService _submissionService = SubmissionService();

  List<Classwork> _allClasswork = [];
  Map<String, int> _submissionCounts = {}; // classworkId -> count
  Map<String, Stream<int>> _submissionStreams = {};

  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchClasswork();
  }

  Future<void> _fetchClasswork() async {
    setState(() => _isLoading = true);
    try {
      _allClasswork =
          await _service.fetchClassworkForClass(widget.classroom.classId);

      // Set up real-time listeners for each classwork
      for (var cw in _allClasswork) {
        _setupSubmissionListener(cw.classworkId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load classwork'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setupSubmissionListener(String classworkId) {
    if (_submissionStreams.containsKey(classworkId)) return;

    final stream = _submissionService.submissionsCountStream(classworkId);
    _submissionStreams[classworkId] = stream;

    stream.listen((count) {
      setState(() {
        _submissionCounts[classworkId] = count;
      });
    });
  }

  void _showCreateDialog({Classwork? classwork}) {
    showDialog<Classwork>(
      context: context,
      builder: (_) => CreateClassworkDialog(
        classroom: widget.classroom,
        adminId: widget.adminId,
        existingClasswork: classwork,
      ),
    ).then((newClasswork) async {
      if (newClasswork == null) return;

      if (classwork != null) {
        bool success = await _service.updateClasswork(newClasswork);
        _fetchClasswork();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Classwork updated successfully'
                : 'Failed to update classwork'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      } else {
        String? id = await _service.createClasswork(newClasswork);
        _fetchClasswork();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(id != null
                ? 'Classwork created successfully'
                : 'Failed to create classwork'),
            backgroundColor: id != null ? Colors.green : Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _deleteClasswork(Classwork cw) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Classwork'),
        content: Text('Delete "${cw.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    bool success = await _service.deleteClasswork(
        cw.classworkId, widget.classroom.classId);
    _fetchClasswork();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Classwork deleted successfully'
            : 'Failed to delete classwork'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  List<Classwork> _filterClasswork(String tab) {
    final now = DateTime.now();
    if (tab == 'Upcoming') {
      return _allClasswork
          .where((cw) => cw.dueDate != null && cw.dueDate!.isAfter(now))
          .toList();
    } else if (tab == 'Overdue') {
      return _allClasswork.where((cw) => cw.isOverdue).toList();
    } else {
      return _allClasswork;
    }
  }

  Color _colorForClasswork(Classwork cw) {
    if (cw.isOverdue) return Colors.red;
    if (cw.dueDate != null &&
        cw.dueDate!.isBefore(DateTime.now().add(const Duration(days: 3)))) {
      return Colors.orange;
    }
    return Colors.green;
  }

  IconData _iconForType(ClassworkType type) {
    switch (type) {
      case ClassworkType.assignment:
        return Ionicons.document_text;
      case ClassworkType.quiz:
        return Ionicons.help_circle;
      case ClassworkType.reading:
        return Ionicons.book;
      case ClassworkType.project:
        return Ionicons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage Classwork'),
            Text(widget.classroom.className,
                style: const TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: ColorPalette.secondary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Overdue'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: ['Upcoming', 'Overdue', 'All'].map((tab) {
                final list = _filterClasswork(tab);
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Ionicons.folder_open_outline,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No $tab classwork',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateDialog(),
                          icon: const Icon(Ionicons.add),
                          label: const Text('Create Classwork'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.secondary,
                              foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final cw = list[i];
                    final color = _colorForClasswork(cw);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: color, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () => _showCreateDialog(classwork: cw),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.1),
                          child: Icon(_iconForType(cw.type), color: color),
                        ),
                        title: Text(cw.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cw.description,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (cw.attachmentUrl != null)
                                  const Icon(Ionicons.attach,
                                      size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                    cw.dueDate != null
                                        ? 'Due: ${cw.formattedDueDate}'
                                        : 'No due date',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                                const Spacer(),
                                if (_submissionCounts[cw.classworkId] != null)
                                  GestureDetector(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (_) => SubmissionsDetailDialog(
                                        classworkId: cw.classworkId,
                                        submissionService: _submissionService,
                                      ),
                                    ),
                                    child: Chip(
                                      label: Text(
                                          '${_submissionCounts[cw.classworkId]} submitted'),
                                      backgroundColor:
                                          Colors.green.withOpacity(0.1),
                                      labelStyle: const TextStyle(
                                          color: Colors.green, fontSize: 12),
                                    ),
                                  ),
                              ],
                            )
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                          onSelected: (v) {
                            if (v == 'edit') _showCreateDialog(classwork: cw);
                            if (v == 'delete') _deleteClasswork(cw);
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        backgroundColor: ColorPalette.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Ionicons.add),
      ),
    );
  }
}
