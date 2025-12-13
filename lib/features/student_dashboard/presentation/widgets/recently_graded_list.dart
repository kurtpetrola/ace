// lib/features/student_dashboard/presentation/widgets/recently_graded_list.dart

import 'package:flutter/material.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/models/submission.dart';

class RecentlyGradedList extends StatelessWidget {
  final List<Classwork> classworkList;
  final Map<String, Submission> submissionMap;

  const RecentlyGradedList({
    super.key,
    required this.classworkList,
    required this.submissionMap,
  });

  @override
  Widget build(BuildContext context) {
    if (classworkList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.history,
                  size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Recently Graded',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Container(
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
          child: Column(
            children: [
              for (int i = 0; i < classworkList.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                _buildItem(context, classworkList[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildItem(BuildContext context, Classwork c) {
    final submission = submissionMap[c.classworkId];
    if (submission == null) return const SizedBox.shrink();

    final grade = submission.grade;
    final maxPoints = c.points;
    final isPassing = (grade ?? 0) >= (maxPoints / 2); // Simple 50% pass check

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isPassing
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPassing ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          color: isPassing ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        c.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        c.type.displayName,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$grade / $maxPoints',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPassing ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
