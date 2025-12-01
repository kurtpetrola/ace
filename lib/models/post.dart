// lib/models/post.dart

import 'package:firebase_database/firebase_database.dart';

class Post {
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;

  Post({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor to build the Post object from Firebase Realtime Database snapshot
  factory Post.fromJson(Map<String, dynamic> json, String postId) {
    return Post(
      postId: postId,
      authorId: json['authorId'] as String? ?? 'Unknown ID',
      authorName: json['authorName'] as String? ?? 'Unknown User',
      content: json['content'] as String? ?? '',
      // Timestamps from Firebase are milliseconds since epoch (int)
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int? ?? 0),
    );
  }

  // Converts the Post object to JSON for saving to Firebase
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'authorName': authorName,
        'content': content,
        // Use ServerValue.timestamp for accurate, server-side generated timestamp
        'timestamp': ServerValue.timestamp,
      };
}
