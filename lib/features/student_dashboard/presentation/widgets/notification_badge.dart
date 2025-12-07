// lib/features/student_dashboard/presentation/widgets/notification_badge.dart

import 'package:flutter/material.dart';
import 'package:ace/services/notification_service.dart';
import 'package:ace/core/constants/app_colors.dart';

class NotificationBadge extends StatelessWidget {
  final String studentId;
  final VoidCallback onTap;

  const NotificationBadge({
    super.key,
    required this.studentId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();

    return StreamBuilder<int>(
      stream: notificationService.getUnreadCountStream(studentId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, size: 28),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: onTap,
        );
      },
    );
  }
}
