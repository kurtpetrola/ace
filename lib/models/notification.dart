// lib/models/notification.dart

enum NotificationType {
  newClasswork,
  gradePosted,
  announcement,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.newClasswork:
        return 'New Classwork';
      case NotificationType.gradePosted:
        return 'Grade Posted';
      case NotificationType.announcement:
        return 'Announcement';
    }
  }
}

class AppNotification {
  final String notificationId;
  final String studentId;
  final String classId;
  final String? classworkId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.notificationId,
    required this.studentId,
    required this.classId,
    this.classworkId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  /// Convert to Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'classId': classId,
      'classworkId': classworkId,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create from Firebase JSON
  factory AppNotification.fromJson(
      String notificationId, Map<String, dynamic> json) {
    return AppNotification(
      notificationId: notificationId,
      studentId: json['studentId'] ?? '',
      classId: json['classId'] ?? '',
      classworkId: json['classworkId'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.announcement,
      ),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  AppNotification copyWith({
    String? notificationId,
    String? studentId,
    String? classId,
    String? classworkId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      notificationId: notificationId ?? this.notificationId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      classworkId: classworkId ?? this.classworkId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
