import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripmaster/page/board/review/post/post_page/edit_post_screen.dart';
import '../../../widgets/card/post_card.dart';

class MyPostTab extends StatefulWidget {
  final String userId;

  const MyPostTab({
    super.key,
    required this.userId,
  });

  @override
  State<MyPostTab> createState() => _MyPostTabState();
}

class _MyPostTabState extends State<MyPostTab> {
  @override
  void initState() {
    super.initState();
    print('MyPostTab initialized with userId: ${widget.userId}');
  }

  String _getCurrentUserId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid ?? '';
  }

  Future<void> _toggleLike(String postId) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId.isEmpty) {
        debugPrint('No user logged in for like action');
        return;
      }

      final postRef = FirebaseFirestore.instance.collection('Post').doc(postId);

      final likeQuery = await FirebaseFirestore.instance
          .collection('Like')
          .where('post_id', isEqualTo: postId)
          .where('user_id', isEqualTo: currentUserId)
          .get();

      if (likeQuery.docs.isNotEmpty) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final postDoc = await transaction.get(postRef);
          if (!postDoc.exists) {
            throw Exception('Post does not exist!');
          }

          transaction.delete(likeQuery.docs.first.reference);
          transaction.update(postRef, {'post_like': FieldValue.increment(-1)});
        });
      } else {
        final likeRef = FirebaseFirestore.instance.collection('Like').doc();
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final postDoc = await transaction.get(postRef);
          if (!postDoc.exists) {
            throw Exception('Post does not exist!');
          }

          transaction.set(likeRef, {
            'post_id': postId,
            'user_id': currentUserId,
            'like_id': likeRef.id,
            'created_at': FieldValue.serverTimestamp()
          });
          transaction.update(postRef, {'post_like': FieldValue.increment(1)});
        });
      }
    } catch (e) {
      debugPrint('Error in toggleLike: $e');
    }
  }

  Future<void> _toggleBookmark(String postId) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId.isEmpty) {
        debugPrint('No user logged in for bookmark action');
        return;
      }

      final String bookmarkId = '${currentUserId}_$postId';
      final bookmarkRef =
          FirebaseFirestore.instance.collection('Bookmark').doc(bookmarkId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final bookmarkDoc = await transaction.get(bookmarkRef);

        if (bookmarkDoc.exists) {
          transaction.delete(bookmarkRef);
        } else {
          transaction.set(bookmarkRef, {
            'book_date': FieldValue.serverTimestamp(),
            'post_id': postId,
            'user_id': currentUserId,
          });
        }
      });
    } catch (e) {
      debugPrint('Error in toggleBookmark: $e');
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId.isEmpty) return;

      final postDoc =
          await FirebaseFirestore.instance.collection('Post').doc(postId).get();

      if (!postDoc.exists || postDoc.data()?['user_id'] != currentUserId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only delete your own posts')),
          );
        }
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        final batch = FirebaseFirestore.instance.batch();

        final likesSnapshot = await FirebaseFirestore.instance
            .collection('Like')
            .where('post_id', isEqualTo: postId)
            .get();
        for (var doc in likesSnapshot.docs) {
          batch.delete(doc.reference);
        }

        final bookmarksSnapshot = await FirebaseFirestore.instance
            .collection('Bookmark')
            .where('post_id', isEqualTo: postId)
            .get();
        for (var doc in bookmarksSnapshot.docs) {
          batch.delete(doc.reference);
        }

        final commentsSnapshot = await FirebaseFirestore.instance
            .collection('Comment')
            .where('post_id', isEqualTo: postId)
            .get();
        for (var doc in commentsSnapshot.docs) {
          batch.delete(doc.reference);
        }

        batch.delete(FirebaseFirestore.instance.collection('Post').doc(postId));

        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post')),
        );
      }
    }
  }

  Future<void> _editPost(String postId, Map<String, dynamic> postData) async {
    try {
      final currentUserId = _getCurrentUserId();
      if (currentUserId.isEmpty) return;

      if (postData['user_id'] != currentUserId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only edit your own posts')),
          );
        }
        return;
      }

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
          const SnackBar(content: Text('Post updated successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error editing post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to edit post')),
        );
      }
    }
  }

  void _showPostOptions(
      BuildContext context, String postId, Map<String, dynamic> postData) {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty || currentUserId != postData['user_id']) return;

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
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _editPost(postId, postData);
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
    if (widget.userId.isEmpty) {
      debugPrint('Invalid userId provided to MyPostTab');
      return const Center(child: Text('Invalid user ID'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Post')
          .where('user_id', isEqualTo: widget.userId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .handleError((error) {
        debugPrint('Firestore Error: $error');
        return Stream.empty();
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('StreamBuilder Error: ${snapshot.error}');
          return Center(child: Text('Error loading posts: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          debugPrint('No posts found for userId: ${widget.userId}');
          return const Center(
            child: Text(
              'No posts yet',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
          );
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            final userId = post['user_id'] ?? '';
            final postId = posts[index].id;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Like')
                  .where('post_id', isEqualTo: postId)
                  .where('user_id', isEqualTo: _getCurrentUserId())
                  .snapshots(),
              builder: (context, likeSnapshot) {
                final isLiked = likeSnapshot.data?.docs.isNotEmpty ?? false;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Bookmark')
                      .where('post_id', isEqualTo: postId)
                      .where('user_id', isEqualTo: _getCurrentUserId())
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
    );
  }
}
