import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final QuerySnapshot postSnapshot = await _firestore
          .collection('Post')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return postSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'post_id': doc.id,
          'post_title': data['post_title'] ?? '',
          'post_description': data['post_description'] ?? '',
          'post_image': data['post_image'] ?? [],
          'post_like': data['post_like'] ?? 0,
          'post_share': data['post_share'] ?? 0,
          'user_id': data['user_id'] ?? '',
          'timestamp': data['timestamp'] ?? Timestamp.now(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching user posts: $e');
      return [];
    }
  }
}
