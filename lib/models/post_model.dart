import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final int likes;
  final int shares;
  final String userId;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.likes,
    required this.shares,
    required this.userId,
    required this.timestamp,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['post_id'] ?? '',
      title: map['post_title'] ?? '',
      description: map['post_description'] ?? '',
      images: List<String>.from(map['post_image'] ?? []),
      likes: map['post_like'] ?? 0,
      shares: map['post_share'] ?? 0,
      userId: map['user_id'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
