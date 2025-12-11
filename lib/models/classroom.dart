import 'package:hive/hive.dart';

part 'classroom.g.dart';

@HiveType(typeId: 0)
class Classroom {
  @HiveField(0)
  final String classId;

  @HiveField(1)
  final String className;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String creator;

  // This will store a URL or asset path string.
  @HiveField(4)
  final String bannerImgPath;

  @HiveField(5)
  final String? teacherId; // Added for linking to Teacher account

  Classroom({
    required this.classId,
    required this.className,
    required this.description,
    required this.creator,
    required this.bannerImgPath,
    this.teacherId,
  });

  factory Classroom.fromJson(String id, Map<String, dynamic> json) {
    return Classroom(
      classId: id,
      className: json['className'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'No description provided.',
      creator: json['creator'] as String? ?? 'Unknown Teacher',
      bannerImgPath: json['bannerImgPath'] as String? ??
          'assets/images/banner/banner_image_8.jpg', // Default changed to a valid file
      teacherId: json['teacherId'] as String?,
    );
  }

  // Method for standard serialization (e.g., for local storage/display)
  Map<String, dynamic> toJson() => {
        'classId': classId,
        'className': className,
        'description': description,
        'creator': creator,
        'bannerImgPath': bannerImgPath,
        'teacherId': teacherId,
      };

  // Method specifically for saving to Firebase Realtime DB, excluding the classId
  // as it is used as the node key.
  Map<String, dynamic> toFirebaseJson() => {
        'className': className,
        'description': description,
        'creator': creator,
        'bannerImgPath': bannerImgPath,
        'teacherId': teacherId,
      };
}

// Example static list used as a temporary mock for demonstration purposes
final List<Classroom> mockClassroomList = [
  Classroom(
    classId: 'MATH101',
    className: 'Calculus I',
    description: 'Introduction to Derivatives and Integrals.',
    creator: 'Dr. Evelyn Reed',
    bannerImgPath: 'assets/images/banner/banner_image_1.jpg',
  ),
  Classroom(
    classId: 'CS201',
    className: 'Data Structures',
    description: 'Arrays, Linked Lists, and Trees.',
    creator: 'Prof. Alan Turing',
    bannerImgPath: 'assets/images/banner/banner_image_2.jpg',
  ),
  // Add more mock classes for testing admin enrollment
  Classroom(
    classId: 'HIST305',
    className: 'World History Since 1945',
    description: 'A look at the post-WWII era.',
    creator: 'Ms. Clara Barton',
    bannerImgPath: 'assets/images/banner/banner_image_3.jpg',
  ),
];
