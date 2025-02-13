import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripmaster/page/profile/profile_page.dart';

class CommentsSection extends StatefulWidget {
  final String postId;
  final Function(String commentId) onCommentAdded;

  const CommentsSection({
    Key? key,
    required this.postId,
    required this.onCommentAdded,
  }) : super(key: key);

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: CommentList(postId: widget.postId),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  UserAvatar(
                      userId: FirebaseAuth.instance.currentUser?.uid ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add comment',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null &&
                          commentController.text.isNotEmpty) {
                        try {
                          final commentRef = FirebaseFirestore.instance
                              .collection('Comment')
                              .doc();
                          final commentData = {
                            'comment_id': commentRef.id,
                            'comment_text': commentController.text,
                            'user_id': currentUser.uid,
                            'post_id': widget.postId,
                            'created_at': FieldValue.serverTimestamp(),
                          };
                          await commentRef.set(commentData);

                          // เรียก callback เพื่อสร้างการแจ้งเตือน
                          widget.onCommentAdded(commentRef.id);

                          commentController.clear();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          print('Error adding comment: $e');
                        }
                      }
                    },
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class CommentList extends StatelessWidget {
  final String postId;

  const CommentList({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Comment')
          .where('post_id', isEqualTo: postId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error loading comments: ${snapshot.error}');
          return const Center(child: Text('Error loading comments'));
        }

        final comments = snapshot.data?.docs ?? [];

        if (comments.isEmpty) {
          return const Center(child: Text('No comments yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final commentData = comments[index].data() as Map<String, dynamic>?;
            if (commentData == null) return const SizedBox.shrink();

            return CommentItem(comment: commentData);
          },
        );
      },
    );
  }
}

class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;

  const CommentItem({
    super.key,
    required this.comment,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController =
        TextEditingController(text: widget.comment['comment_text']);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.black87),
              title: const Text(
                'Edit Comment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  isEditing = true;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Comment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteComment();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteComment() async {
    try {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (shouldDelete ?? false) {
        await FirebaseFirestore.instance
            .collection('Comment')
            .doc(widget.comment['comment_id'])
            .delete();
      }
    } catch (e) {
      print('Error deleting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment')),
        );
      }
    }
  }

  Future<void> _updateComment() async {
    if (_editController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('Comment')
          .doc(widget.comment['comment_id'])
          .update({
        'comment_text': _editController.text.trim(),
        'edited_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          isEditing = false;
        });
      }
    } catch (e) {
      print('Error updating comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update comment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCommentOwner = currentUserId == widget.comment['user_id'];

    return GestureDetector(
      onLongPress: isCommentOwner ? _showActionSheet : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(userId: widget.comment['user_id']),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UsernameFuture(userId: widget.comment['user_id']),
                  const SizedBox(height: 2),
                  if (isEditing)
                    TextField(
                      controller: _editController,
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = false;
                                  _editController.text =
                                      widget.comment['comment_text'];
                                });
                              },
                              icon: const Icon(Icons.close, color: Colors.grey),
                            ),
                            IconButton(
                              onPressed: _updateComment,
                              icon: const Icon(Icons.check, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      widget.comment['comment_text'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String userId;

  const UserAvatar({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          String? profileImage;
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            profileImage = userData?['profile_image'] as String?;
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userId: userId),
                ),
              );
            },
            child: profileImage != null && profileImage.isNotEmpty
                ? CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(profileImage),
                  )
                : const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
          );
        });
  }
}

class UsernameFuture extends StatelessWidget {
  final String userId;

  const UsernameFuture({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('User').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final username = userData?['username'] ?? 'Anonymous';
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userId: userId),
                ),
              );
            },
            child: Text(
              username,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          );
        }
        return const Text(
          'Anonymous',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        );
      },
    );
  }
}
