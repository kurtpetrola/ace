// lib/models/classroom.dart

// NOTE: Since AssetImage is used in your current code, the bannerImg here
// represents a path or an identifier, not the image itself.
class Classroom {
  final String classId;
  final String className;
  final String description;
  final String creator;
  // This will store a URL or asset path string.
  final String bannerImgPath;

  Classroom({
    required this.classId,
    required this.className,
    required this.description,
    required this.creator,
    required this.bannerImgPath,
  });

  factory Classroom.fromJson(String id, Map<String, dynamic> json) {
    return Classroom(
      classId: id,
      className: json['className'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'No description provided.',
      creator: json['creator'] as String? ?? 'Unknown Teacher',
      bannerImgPath: json['bannerImgPath'] as String? ??
          'assets/images/banner/default.jpg',
    );
  }

  // Method for standard serialization (e.g., for local storage/display)
  Map<String, dynamic> toJson() => {
        'classId': classId,
        'className': className,
        'description': description,
        'creator': creator,
        'bannerImgPath': bannerImgPath,
      };

  // Method specifically for saving to Firebase Realtime DB, excluding the classId
  // as it is used as the node key.
  Map<String, dynamic> toFirebaseJson() => {
        'className': className,
        'description': description,
        'creator': creator,
        'bannerImgPath': bannerImgPath,
      };
}

// Example static list used as a temporary mock for demonstration purposes
final List<Classroom> mockClassroomList = [
  Classroom(
    classId: 'MATH101',
    className: 'Calculus I',
    description: 'Introduction to Derivatives and Integrals.',
    creator: 'Dr. Evelyn Reed',
    bannerImgPath: 'assets/images/banner/banner1.jpg',
  ),
  Classroom(
    classId: 'CS201',
    className: 'Data Structures',
    description: 'Arrays, Linked Lists, and Trees.',
    creator: 'Prof. Alan Turing',
    bannerImgPath: 'assets/images/banner/banner2.jpg',
  ),
  // Add more mock classes for testing admin enrollment
  Classroom(
    classId: 'HIST305',
    className: 'World History Since 1945',
    description: 'A look at the post-WWII era.',
    creator: 'Ms. Clara Barton',
    bannerImgPath: 'assets/images/banner/banner3.jpg',
  ),
];
