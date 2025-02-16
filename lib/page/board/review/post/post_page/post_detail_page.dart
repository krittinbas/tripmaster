// file: lib/page/board/review/post/post_page/post_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripmaster/page/board/review/comment/comments_section.dart';
import 'package:tripmaster/page/board/review/post/post_component/post_detail_components.dart';
import '../post_state/post_detail_state.dart';

class PostDetailPage extends StatefulWidget {
  final List<String> imageUrls;
  final String userId;
  final String location;
  final String topic;
  final String description;
  final int likes;
  final int comments;
  final int shares;
  final String postId;

  const PostDetailPage({
    super.key,
    required this.imageUrls,
    required this.userId,
    required this.location,
    required this.topic,
    required this.description,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.postId,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostDetailStateManager stateManager;

  Future<void> _createCommentNotification(String commentId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // ไม่สร้างการแจ้งเตือนถ้าคอมเมนต์โพสต์ตัวเอง
    if (currentUser.uid == widget.userId) return;

    try {
      // ดึงข้อมูล username ของผู้ใช้ปัจจุบัน
      final userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUser.uid)
          .get();

      final username = userDoc.data()?['username'] ?? 'unknown';

      // สร้างการแจ้งเตือนใหม่
      await FirebaseFirestore.instance.collection('Notifications').add({
        'recipient_id': widget.userId,
        'sender_id': currentUser.uid,
        'sender_username': username,
        'type': 'comment',
        'post_id': widget.postId,
        'comment_id': commentId,
        'created_at': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error creating comment notification: $e');
    }
  }

  void showCommentSection(BuildContext context, String postId,
      PostDetailStateManager stateManager) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSection(
        postId: postId,
        onCommentAdded: (String commentId) async {
          await _createCommentNotification(commentId);
          stateManager.refreshCommentCount();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    stateManager = PostDetailStateManager(widget);
    stateManager.initialize();
  }

  @override
  void dispose() {
    stateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageCarousel(
                    imageUrls: widget.imageUrls,
                    onPageChanged: stateManager.updateCurrentImageIndex,
                  ),
                  UserInfoSection(
                    location: widget.location,
                    userId: widget.userId,
                    userDataStream: stateManager.userDataStream,
                    postStream: stateManager.postStream,
                  ),
                  ContentSection(
                    topic: widget.topic,
                    description: widget.description,
                  ),
                ],
              ),
            ),
          ),
          InteractionBar(
            isLiked: stateManager.isLiked,
            isBookmarked: stateManager.isBookmarked,
            postStream: stateManager.postStream,
            commentCountStream: stateManager.commentCountStream,
            shares: widget.shares,
            onLike: stateManager.handleLike,
            onComment: () =>
                showCommentSection(context, widget.postId, stateManager),
            onBookmark: stateManager.toggleBookmark,
          ),
          const SizedBox(height: 35),
        ],
      ),
    );
  }
}
