import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/card/post_card.dart';

class BookmarkTab extends StatelessWidget {
  final String userId;

  const BookmarkTab({
    super.key,
    required this.userId,
  });

  Future<void> _toggleLike(String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final likeRef = FirebaseFirestore.instance.collection('Like').doc();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Like')
        .where('post_id', isEqualTo: postId)
        .where('user_id', isEqualTo: currentUser.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.delete();
      await FirebaseFirestore.instance
          .collection('Post')
          .doc(postId)
          .update({'post_like': FieldValue.increment(-1)});
    } else {
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bookmark')
          .where('user_id', isEqualTo: userId)
          .orderBy('book_date', descending: true) // เรียงลำดับตาม book_date
          .snapshots(),
      builder: (context, bookmarkSnapshot) {
        if (bookmarkSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!bookmarkSnapshot.hasData || bookmarkSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No bookmarked posts',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
          );
        }

        final bookmarkedPosts = bookmarkSnapshot.data!.docs;
        final postIds =
            bookmarkedPosts.map((doc) => doc['post_id'] as String).toList();

        if (postIds.isEmpty) {
          return const Center(child: Text('No bookmarked posts'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Post')
              .where(FieldPath.documentId, whereIn: postIds)
              .snapshots(),
          builder: (context, postSnapshot) {
            if (postSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No posts available'));
            }

            // สร้าง Map ของ bookmark dates
            final bookmarkDates = {
              for (var doc in bookmarkedPosts)
                doc['post_id'] as String:
                    (doc['book_date'] as Timestamp?)?.toDate()
            };

            // เรียงลำดับโพสต์ตาม bookmark date
            final posts = postSnapshot.data!.docs.toList()
              ..sort((a, b) {
                final dateA = bookmarkDates[a.id];
                final dateB = bookmarkDates[b.id];
                if (dateA == null || dateB == null) return 0;
                return dateB.compareTo(dateA);
              });

            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data() as Map<String, dynamic>;
                final postId = posts[index].id;
                final userId = post['user_id'] ?? '';

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Like')
                      .where('post_id', isEqualTo: postId)
                      .where('user_id',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, likeSnapshot) {
                    final isLiked = likeSnapshot.data?.docs.isNotEmpty ?? false;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Bookmark')
                          .where('post_id', isEqualTo: postId)
                          .where('user_id',
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, currentBookmarkSnapshot) {
                        final isBookmarked =
                            currentBookmarkSnapshot.data?.docs.isNotEmpty ??
                                false;

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
                              imageUrls:
                                  List<String>.from(post['post_image'] ?? []),
                              userId: userId,
                              username: post['username'] ?? 'Anonymous',
                              location: post['location'] ?? 'Unknown location',
                              description: post['post_description'] ?? '',
                              postId: postId,
                              isLiked: isLiked,
                              isBookmarked: isBookmarked,
                              onLikePressed: () => _toggleLike(postId),
                              onBookmarkPressed: () => _toggleBookmark(postId),
                              onMorePressed: () {},
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
        );
      },
    );
  }
}
