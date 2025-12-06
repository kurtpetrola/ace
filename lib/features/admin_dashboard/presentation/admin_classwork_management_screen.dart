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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: ColorPalette.accentBlack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Classwork',
              style: TextStyle(
                color: ColorPalette.accentBlack,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              widget.classroom.className,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorPalette.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: ColorPalette.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Ionicons.folder_open_outline,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No $tab classwork found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get started by creating a new assignment.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateDialog(),
                          icon: const Icon(Ionicons.add),
                          label: const Text('Create Classwork'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final cw = list[i];
                    final color = _colorForClasswork(cw);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Color strip
                              Container(
                                width: 6,
                                color: color,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showCreateDialog(classwork: cw),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Icon Badge
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(_iconForType(cw.type),
                                                  color: color, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    cw.title,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: ColorPalette
                                                          .accentBlack,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    cw.type.displayName,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton(
                                              icon: Icon(Icons.more_vert,
                                                  color: Colors.grey.shade400),
                                              itemBuilder: (_) => [
                                                const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit,
                                                            size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Edit'),
                                                      ],
                                                    )),
                                                const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .delete_outline,
                                                            size: 18,
                                                            color: Colors.red),
                                                        SizedBox(width: 8),
                                                        Text('Delete',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ],
                                                    )),
                                              ],
                                              onSelected: (v) {
                                                if (v == 'edit')
                                                  _showCreateDialog(
                                                      classwork: cw);
                                                if (v == 'delete')
                                                  _deleteClasswork(cw);
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          cw.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              height: 1.4),
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Ionicons.calendar_outline,
                                                size: 14,
                                                color: Colors.grey.shade500),
                                            const SizedBox(width: 6),
                                            Text(
                                              cw.dueDate != null
                                                  ? cw.formattedDueDate
                                                  : 'No due date',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade600),
                                            ),
                                            if (cw.isOverdue) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text('OVERDUE',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              )
                                            ],
                                            const Spacer(),
                                            if (_submissionCounts[
                                                    cw.classworkId] !=
                                                null)
                                              InkWell(
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      SubmissionsDetailDialog(
                                                    classworkId: cw.classworkId,
                                                    submissionService:
                                                        _submissionService,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: ColorPalette.primary
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Ionicons
                                                              .checkmark_done_circle,
                                                          size: 14,
                                                          color: ColorPalette
                                                              .primary),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${_submissionCounts[cw.classworkId]} Submitted',
                                                        style: const TextStyle(
                                                          color: ColorPalette
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        backgroundColor: ColorPalette.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Ionicons.add),
        label: const Text('Add New'),
      ),
    );
  }
}
