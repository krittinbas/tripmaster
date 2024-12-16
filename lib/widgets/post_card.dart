import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final int likes;
  final int comments;
  final int shares;

  const PostCard({
    super.key,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.green, // Placeholder for post image
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Color(0xFF000D34)),
                    const SizedBox(width: 8),
                    Text('$likes'),
                    const SizedBox(width: 16),
                    const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF000D34)),
                    const SizedBox(width: 8),
                    Text('$comments'),
                    const SizedBox(width: 16),
                    const Icon(Icons.send, color: Color(0xFF000D34)),
                    const SizedBox(width: 8),
                    Text('$shares'),
                  ],
                ),
                const Icon(Icons.bookmark, color: Color(0xFF000D34)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text('Post\'s Topic'),
          ),
        ],
      ),
    );
  }
}
