import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/card/post_card.dart';
import 'post/post_page/addpost_page.dart';
import 'post/post_page/edit_post_screen.dart';

class ReviewSection extends StatefulWidget {
  const ReviewSection({super.key});

  @override
  _ReviewSectionState createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
// เพิ่มฟังก์ชันสร้างการแจ้งเตือนสำหรับการไลค์
  Future<void> _createLikeNotification(
      String postId, String postOwnerId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // ไม่สร้างการแจ้งเตือนถ้าไลค์โพสต์ตัวเอง
    if (currentUser.uid == postOwnerId) return;

    try {
      // ดึงข้อมูล username ของผู้ใช้ปัจจุบัน
      final userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser.uid)
          .get();

      final username = userDoc.data()?['username'] ?? 'unknown';

      // สร้างการแจ้งเตือนใหม่
      await FirebaseFirestore.instance.collection('Notifications').add({
        'recipient_id': postOwnerId,
        'sender_id': currentUser.uid,
        'sender_username': username,
        'type': 'like',
        'post_id': postId,
        'created_at': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error creating like notification: $e');
    }
  }

  Future<void> _toggleLike(String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // ดึงข้อมูลโพสต์เพื่อหาเจ้าของโพสต์
      final postDoc =
          await FirebaseFirestore.instance.collection('Post').doc(postId).get();

      if (!postDoc.exists) return;

      final postData = postDoc.data();
      if (postData == null) return;

      final postOwnerId = postData['user_id'] as String?;
      if (postOwnerId == null) return;

      final likeRef = FirebaseFirestore.instance.collection('Like').doc();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Like')
          .where('post_id', isEqualTo: postId)
          .where('user_id', isEqualTo: currentUser.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // ถ้ามีการกดไลค์แล้ว ให้ลบออก
        await querySnapshot.docs.first.reference.delete();
        await FirebaseFirestore.instance
            .collection('Post')
            .doc(postId)
            .update({'post_like': FieldValue.increment(-1)});

        // ลบการแจ้งเตือนที่เกี่ยวข้องกับการไลค์นี้
        final notificationQuery = await FirebaseFirestore.instance
            .collection('Notifications')
            .where('sender_id', isEqualTo: currentUser.uid)
            .where('post_id', isEqualTo: postId)
            .where('type', isEqualTo: 'like')
            .get();

        for (var doc in notificationQuery.docs) {
          await doc.reference.delete();
        }
      } else {
        // ถ้ายังไม่มีการกดไลค์ ให้เพิ่มเข้าไป
        await likeRef.set({
          'post_id': postId,
          'user_id': currentUser.uid,
          'like_id': likeRef.id,
          'created_at': FieldValue.serverTimestamp()
        });

        await FirebaseFirestore.instance
            .collection('Post')
            .doc(postId)
            .update({'post_like': FieldValue.increment(1)});

        // สร้างการแจ้งเตือนเมื่อกดไลค์
        await _createLikeNotification(postId, postOwnerId);
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _toggleBookmark(String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String bookmarkId = '${currentUser.uid}_${postId}';
    final bookmarkRef =
        FirebaseFirestore.instance.collection('Bookmark').doc(bookmarkId);

    final bookmarkDoc = await bookmarkRef.get();

    if (bookmarkDoc.exists) {
      await bookmarkRef.delete();
    } else {
      await bookmarkRef.set({
        'book_date': FieldValue.serverTimestamp(),
        'post_id': postId,
        'user_id': currentUser.uid,
      });
    }
  }

  Future<bool?> showDeleteConfirmationBottomSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Indicator bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Delete Post Button
                InkWell(
                  onTap: () => Navigator.pop(context, true),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Delete Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // ตรวจสอบว่าเป็นเจ้าของโพสหรือไม่
      final postDoc =
          await FirebaseFirestore.instance.collection('Post').doc(postId).get();

      if (!postDoc.exists || postDoc.data()?['user_id'] != currentUser.uid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only delete your own posts')),
          );
        }
        return;
      }

      final confirmed = await showDeleteConfirmationBottomSheet(context);

      if (confirmed == true) {
        final batch = FirebaseFirestore.instance.batch();

        // ลบไลค์ทั้งหมด
        final likesSnapshot = await FirebaseFirestore.instance
            .collection('Like')
            .where('post_id', isEqualTo: postId)
            .get();
        for (var doc in likesSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // ลบบุ๊คมาร์คทั้งหมด
        final bookmarksSnapshot = await FirebaseFirestore.instance
            .collection('Bookmark')
            .where('post_id', isEqualTo: postId)
            .get();
        for (var doc in bookmarksSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // ลบคอมเมนต์ทั้งหมด
        final commentsSnapshot = await FirebaseFirestore.instance
            .collection('Comment')
            .where('post_id', isEqualTo: postId)
            .get();
        for (var doc in commentsSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // ลบโพส
        batch.delete(FirebaseFirestore.instance.collection('Post').doc(postId));

        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      }
    } catch (e) {
      print('Error deleting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post')),
        );
      }
    }
  }

  void _showPostOptions(
      BuildContext context, String postId, Map<String, dynamic> postData) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != postData['user_id']) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Indicator bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Edit Post Button
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPostScreen(
                          postId: postId,
                          postData: postData,
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Post updated successfully')),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF000D34),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Edit Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000D34),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Delete Post Button
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _deletePost(postId);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Delete Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Post')
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No posts available'));
              }

              final posts = snapshot.data!.docs;

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index].data() as Map<String, dynamic>;
                  final userId = post['user_id'] ?? '';
                  final postId = posts[index].id;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Like')
                        .where('post_id', isEqualTo: postId)
                        .where('user_id',
                            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, likeSnapshot) {
                      final isLiked =
                          likeSnapshot.data?.docs.isNotEmpty ?? false;

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Bookmark')
                            .where('post_id', isEqualTo: postId)
                            .where('user_id',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, bookmarkSnapshot) {
                          final isBookmarked =
                              bookmarkSnapshot.data?.docs.isNotEmpty ?? false;

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Comment')
                                .where('post_id', isEqualTo: postId)
                                .snapshots(),
                            builder: (context, commentSnapshot) {
                              final commentCount =
                                  commentSnapshot.data?.docs.length ?? 0;

                              return PostCard(
                                likes: post['post_like'] ?? 0,
                                comments: commentCount,
                                shares: post['post_share'] ?? 0,
                                topic: post['post_title'] ?? 'Untitled',
                                imageUrls: (post['post_image'] != null &&
                                        post['post_image'] is List &&
                                        post['post_image'].isNotEmpty)
                                    ? List<String>.from(post['post_image'])
                                    : ['https://via.placeholder.com/300'],
                                userId: userId,
                                username: post['username'] ?? 'Anonymous',
                                location:
                                    post['location'] ?? 'Unknown location',
                                description: post['post_description'] ?? '',
                                postId: postId,
                                isLiked: isLiked,
                                isBookmarked: isBookmarked,
                                onLikePressed: () => _toggleLike(postId),
                                onBookmarkPressed: () =>
                                    _toggleBookmark(postId),
                                onMorePressed: () =>
                                    _showPostOptions(context, postId, post),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPostPage(),
                  ),
                );
              },
              backgroundColor: Colors.white,
              elevation: 5,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Color(0xFF000D34),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
