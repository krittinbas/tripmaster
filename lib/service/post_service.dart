import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Stream controller for real-time updates
  final _postsStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get postsStream =>
      _postsStreamController.stream;

  // Initialize real-time listener for posts
  void initPostsListener() {
    _firestore
        .collection('Post')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final posts = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
      _postsStreamController.add(posts);
    }, onError: (error) {
      print('Error in posts listener: $error');
    });
  }

  // เพิ่มฟังก์ชันใหม่สำหรับนับจำนวนโพสต์ของผู้ใช้
  Stream<int> getUserPostCount(String userId) {
    return _firestore
        .collection('Post')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // เพิ่มฟังก์ชันสำหรับดึงโพสต์ของผู้ใช้เฉพาะคน
  Stream<List<Map<String, dynamic>>> getUserPosts(String userId) {
    return _firestore
        .collection('Post')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  Future<String> addPost({
    required String userId,
    required String topic,
    required String description,
    List<String>? imageUrls,
    String? locationId,
  }) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      if (topic.trim().isEmpty) {
        throw Exception('Topic cannot be empty');
      }
      if (description.trim().isEmpty) {
        throw Exception('Description cannot be empty');
      }

      final String postId = _uuid.v4();

      // Create post data map
      final Map<String, dynamic> postData = {
        'post_id': postId,
        'user_id': userId,
        'post_title': topic.trim(),
        'post_description': description.trim(),
        'post_image': imageUrls ?? [],
        'post_like': 0,
        'post_share': 0,
        'post_comment': 0,
        'post_mention': '',
        'created_at': FieldValue.serverTimestamp(),
        'location_id': locationId ?? '',
        'comment_id': '',
      };

      // Use batch write for better transaction handling
      final WriteBatch batch = _firestore.batch();
      final DocumentReference postRef =
          _firestore.collection('Post').doc(postId);
      batch.set(postRef, postData);

      await batch.commit();

      print('Successfully added post with ID: $postId');
      return postId;
    } catch (e) {
      print('Error in addPost: $e');
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      }
      throw Exception('Failed to add post: $e');
    }
  }

  // Update post likes
  Future<void> updatePostLike(String postId, int newLikeCount) async {
    try {
      await _firestore.collection('Post').doc(postId).update({
        'post_like': newLikeCount,
      });
    } catch (e) {
      throw Exception('Failed to update post likes: $e');
    }
  }

  Future<void> updatePostImages(
      String postId, List<String> newImageUrls) async {
    try {
      await _firestore.collection('Post').doc(postId).update({
        'post_image': newImageUrls,
      });
    } catch (e) {
      throw Exception('Failed to update post images: $e');
    }
  }

  // Dispose of stream controller when no longer needed
  void dispose() {
    _postsStreamController.close();
  }
}
