import 'package:flutter/material.dart';
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
                    postStream: stateManager
                        .postStream, // เปลี่ยนจาก locationStream เป็น postStream
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
