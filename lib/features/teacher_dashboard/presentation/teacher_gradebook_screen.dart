// lib/features/teacher_dashboard/presentation/teacher_gradebook_screen.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/services/classwork_service.dart';
import 'package:ace/features/teacher_dashboard/presentation/teacher_classwork_grades_screen.dart';
import 'package:ionicons/ionicons.dart';

class TeacherGradebookScreen extends StatefulWidget {
  final Classroom classroom;

  const TeacherGradebookScreen({super.key, required this.classroom});

  @override
  State<TeacherGradebookScreen> createState() => _TeacherGradebookScreenState();
}

class _TeacherGradebookScreenState extends State<TeacherGradebookScreen> {
  final ClassworkService _classworkService = ClassworkService();
  List<Classwork> _classworks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClassworks();
  }

  Future<void> _fetchClassworks() async {
    setState(() => _isLoading = true);
    try {
      final data = await _classworkService
          .fetchClassworkForClass(widget.classroom.classId);
      if (mounted) {
        setState(() {
          _classworks = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load assignments')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.classroom.className} Gradebook',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classworks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Ionicons.book_outline,
                          size: 64, color: Theme.of(context).hintColor),
                      const SizedBox(height: 16),
                      Text('No assignments found',
                          style: TextStyle(color: Theme.of(context).hintColor)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _classworks.length,
                  itemBuilder: (context, index) {
                    final cw = _classworks[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: Theme.of(context).cardTheme.color,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          child: Icon(Ionicons.document_text,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(
                          cw.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Due: ${cw.dueDate != null ? cw.formattedDueDate : "No due date"}',
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 12),
                            ),
                            Text(
                              'Points: ${cw.points}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ],
                        ),
                        trailing: Icon(Ionicons.chevron_forward,
                            color: Theme.of(context).hintColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TeacherClassworkGradesScreen(
                                classroom: widget.classroom,
                                classwork: cw,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
