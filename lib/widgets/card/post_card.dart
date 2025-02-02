import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripmaster/page/board/review/post/post_page/post_detail_page.dart';

class PostCard extends StatefulWidget {
  final int likes;
  final int comments;
  final int shares;
  final String topic;
  final List<String> imageUrls;
  final String userId;
  final String username;
  final String location;
  final String description;
  final String postId;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onLikePressed;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onMorePressed;

  const PostCard({
    Key? key,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.topic,
    required this.imageUrls,
    required this.userId,
    required this.username,
    required this.location,
    required this.description,
    required this.postId,
    required this.isLiked,
    required this.isBookmarked,
    required this.onLikePressed,
    required this.onBookmarkPressed,
    required this.onMorePressed,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int currentImageIndex = 0;
  late bool isLiked;
  late bool isBookmarked;
  late int currentLikes;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    currentLikes = widget.likes;
    isBookmarked = widget.isBookmarked;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      isBookmarked = widget.isBookmarked;
    }
    if (oldWidget.isLiked != widget.isLiked) {
      isLiked = widget.isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnPost = currentUser?.uid == widget.userId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(
              imageUrls: widget.imageUrls,
              userId: widget.userId,
              location: widget.location,
              topic: widget.topic,
              description: widget.description,
              likes: currentLikes,
              comments: widget.comments,
              shares: widget.shares,
              postId: widget.postId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 150,
                    child: PageView.builder(
                      onPageChanged: (index) {
                        setState(() {
                          currentImageIndex = index;
                        });
                      },
                      itemCount: widget.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.imageUrls[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Image not available'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // แสดงปุ่ม More เฉพาะเมื่อเป็นโพสของตัวเอง
                if (isOwnPost)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onPressed: widget.onMorePressed,
                      ),
                    ),
                  ),
              ],
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                widget.onLikePressed();
                                setState(() {
                                  isLiked = !isLiked;
                                  currentLikes += isLiked ? 1 : -1;
                                });
                              },
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? Colors.red
                                    : const Color(0xFF000D34),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$currentLikes',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000D34),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Color(0xFF000D34),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.comments}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000D34),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.share_outlined,
                              color: Color(0xFF000D34),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.shares}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000D34),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.onBookmarkPressed();
                            setState(() {
                              isBookmarked = !isBookmarked;
                            });
                          },
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: const Color(0xFF000D34),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.topic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
