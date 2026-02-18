// lib/services/notification_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';
import 'package:ace/models/notification.dart';
import 'package:ace/models/classwork.dart';

class NotificationService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Create notifications for all enrolled students when new classwork is posted
  Future<void> createNotificationForNewClasswork(
    Classwork classwork,
    List<String> studentIds,
    String className,
  ) async {
    if (studentIds.isEmpty) return;

    try {
      final Map<String, dynamic> updates = {};

      for (final studentId in studentIds) {
        final notificationRef = _db.child('Notifications/$studentId').push();
        final notificationId = notificationRef.key!;

        final notification = AppNotification(
          notificationId: notificationId,
          studentId: studentId,
          classId: classwork.classId,
          classworkId: classwork.classworkId,
          title: 'New ${classwork.type.displayName} in $className',
          message: classwork.title,
          type: NotificationType.newClasswork,
          isRead: false,
          createdAt: DateTime.now(),
        );

        updates['Notifications/$studentId/$notificationId'] =
            notification.toJson();
      }

      await _db.update(updates);
    } catch (e) {
      log('Error creating notifications: $e');
    }
  }

  /// Get real-time stream of notifications for a student
  Stream<List<AppNotification>> getStudentNotificationsStream(
      String studentId) {
    return _db
        .child('Notifications/$studentId')
        .orderByChild('createdAt')
        .onValue
        .map((event) {
      final notificationsMap = event.snapshot.value;
      final List<AppNotification> notifications = [];

      if (notificationsMap != null && notificationsMap is Map) {
        final Map<String, dynamic> rawData =
            Map<String, dynamic>.from(notificationsMap);

        rawData.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final Map<String, dynamic> notificationData =
                Map<String, dynamic>.from(value);
            notifications.add(AppNotification.fromJson(key, notificationData));
          }
        });
      }

      // Sort by newest first
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    });
  }

  /// Get count of unread notifications
  Future<int> getUnreadCount(String studentId) async {
    try {
      final snapshot = await _db.child('Notifications/$studentId').get();

      if (!snapshot.exists || snapshot.value == null) {
        return 0;
      }

      final Map<String, dynamic> notificationsMap =
          Map<String, dynamic>.from(snapshot.value as Map);

      int unreadCount = 0;
      notificationsMap.forEach((key, value) {
        if (value is Map && value['isRead'] == false) {
          unreadCount++;
        }
      });

      return unreadCount;
    } catch (e) {
      log('Error getting unread count: $e');
      return 0;
    }
  }

  /// Get real-time stream of unread count
  Stream<int> getUnreadCountStream(String studentId) {
    return _db.child('Notifications/$studentId').onValue.map((event) {
      final notificationsMap = event.snapshot.value;

      if (notificationsMap == null || notificationsMap is! Map) {
        return 0;
      }

      final Map<String, dynamic> rawData =
          Map<String, dynamic>.from(notificationsMap);

      int unreadCount = 0;
      rawData.forEach((key, value) {
        if (value is Map && value['isRead'] == false) {
          unreadCount++;
        }
      });

      return unreadCount;
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId, String studentId) async {
    try {
      await _db
          .child('Notifications/$studentId/$notificationId/isRead')
          .set(true);
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String studentId) async {
    try {
      final snapshot = await _db.child('Notifications/$studentId').get();

      if (!snapshot.exists || snapshot.value == null) {
        return;
      }

      final Map<String, dynamic> notificationsMap =
          Map<String, dynamic>.from(snapshot.value as Map);

      final Map<String, dynamic> updates = {};
      notificationsMap.forEach((notificationId, value) {
        if (value is Map && value['isRead'] == false) {
          updates['Notifications/$studentId/$notificationId/isRead'] = true;
        }
      });

      if (updates.isNotEmpty) {
        await _db.update(updates);
      }
    } catch (e) {
      log('Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(
      String notificationId, String studentId) async {
    try {
      await _db.child('Notifications/$studentId/$notificationId').remove();
    } catch (e) {
      log('Error deleting notification: $e');
    }
  }

  /// Delete all read notifications
  Future<void> clearReadNotifications(String studentId) async {
    try {
      final snapshot = await _db.child('Notifications/$studentId').get();

      if (!snapshot.exists || snapshot.value == null) {
        return;
      }

      final Map<String, dynamic> notificationsMap =
          Map<String, dynamic>.from(snapshot.value as Map);

      final Map<String, dynamic> updates = {};
      notificationsMap.forEach((notificationId, value) {
        if (value is Map && value['isRead'] == true) {
          updates['Notifications/$studentId/$notificationId'] = null;
        }
      });

      if (updates.isNotEmpty) {
        await _db.update(updates);
      }
    } catch (e) {
      log('Error clearing read notifications: $e');
    }
  }
}
