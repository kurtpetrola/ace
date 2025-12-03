// lib/models/classwork.dart

enum ClassworkType {
  assignment,
  quiz,
  reading,
  project;

  String get displayName {
    switch (this) {
      case ClassworkType.assignment:
        return 'Assignment';
      case ClassworkType.quiz:
        return 'Quiz';
      case ClassworkType.reading:
        return 'Reading Material';
      case ClassworkType.project:
        return 'Project';
    }
  }

  static ClassworkType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return ClassworkType.assignment;
      case 'quiz':
        return ClassworkType.quiz;
      case 'reading':
        return ClassworkType.reading;
      case 'project':
        return ClassworkType.project;
      default:
        return ClassworkType.assignment;
    }
  }
}

class Classwork {
  final String classworkId;
  final String classId;
  final String title;
  final String description;
  final ClassworkType type;
  final DateTime? dueDate;
  final int points;
  final String createdBy;
  final DateTime createdAt;
  final String? attachmentUrl;

  Classwork({
    required this.classworkId,
    required this.classId,
    required this.title,
    required this.description,
    required this.type,
    this.dueDate,
    required this.points,
    required this.createdBy,
    required this.createdAt,
    this.attachmentUrl,
  });

  factory Classwork.fromJson(String id, Map<String, dynamic> json) {
    return Classwork(
      classworkId: id,
      classId: json['classId'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? 'No description',
      type: ClassworkType.fromString(json['type'] as String? ?? 'assignment'),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      points: json['points'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? 'Unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      attachmentUrl: json['attachmentUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'classworkId': classworkId,
        'classId': classId,
        'title': title,
        'description': description,
        'type': type.name,
        'dueDate': dueDate?.toIso8601String(),
        'points': points,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'attachmentUrl': attachmentUrl,
      };

  Map<String, dynamic> toFirebaseJson() => {
        'classId': classId,
        'title': title,
        'description': description,
        'type': type.name,
        'dueDate': dueDate?.toIso8601String(),
        'points': points,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'attachmentUrl': attachmentUrl,
      };

  // Helper method to check if classwork is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Helper method to format due date for display
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';
    return '${dueDate!.month}/${dueDate!.day}/${dueDate!.year} at ${dueDate!.hour}:${dueDate!.minute.toString().padLeft(2, '0')}';
  }
}
