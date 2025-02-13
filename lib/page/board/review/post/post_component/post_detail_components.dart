import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripmaster/page/profile/profile_page.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final Function(int) onPageChanged;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.green[700],
        child: PageView.builder(
          onPageChanged: onPageChanged,
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}

class UserInfoSection extends StatelessWidget {
  final String location;
  final String userId;
  final Stream<DocumentSnapshot> userDataStream;
  final Stream<DocumentSnapshot> postStream;

  const UserInfoSection({
    super.key,
    required this.location,
    required this.userId,
    required this.userDataStream,
    required this.postStream,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(userId: userId),
            ),
          );
        },
        child: StreamBuilder<DocumentSnapshot>(
          stream: postStream,
          builder: (context, postSnapshot) {
            String locationId = location;

            if (postSnapshot.hasData && postSnapshot.data!.exists) {
              final postData =
                  postSnapshot.data!.data() as Map<String, dynamic>?;
              if (postData != null) {
                locationId = postData['location_id'] ?? location;
              }
            }

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Location')
                  .doc(locationId)
                  .snapshots(),
              builder: (context, locationSnapshot) {
                String locationName = 'Unknown Location';

                if (locationSnapshot.hasData && locationSnapshot.data!.exists) {
                  final locationData =
                      locationSnapshot.data!.data() as Map<String, dynamic>?;
                  if (locationData != null) {
                    locationName =
                        locationData['location_name'] ?? 'Unknown Location';
                  }
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: userDataStream,
                  builder: (context, userSnapshot) {
                    String displayName = 'Unknown User';
                    String? profileImage;

                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>?;
                      if (userData != null) {
                        displayName = userData['username'] ?? 'Anonymous';
                        profileImage = userData['profile_image'] as String?;
                      }
                    }

                    return Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: profileImage != null && profileImage.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profileImage,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.6, // ปรับความกว้างตามที่ต้องการ
                              child: Text(
                                locationName,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 2, // เพิ่มเป็น 2 บรรทัด
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ContentSection extends StatelessWidget {
  final String topic;
  final String description;

  const ContentSection({
    super.key,
    required this.topic,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class InteractionBar extends StatelessWidget {
  final bool isLiked;
  final bool isBookmarked;
  final Stream<DocumentSnapshot> postStream;
  final Stream<int> commentCountStream;
  final int shares;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;

  const InteractionBar({
    super.key,
    required this.isLiked,
    required this.isBookmarked,
    required this.postStream,
    required this.commentCountStream,
    required this.shares,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onLike,
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28,
                  color: isLiked ? Colors.red : Colors.black,
                ),
                const SizedBox(width: 4),
                StreamBuilder<DocumentSnapshot>(
                  stream: postStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final likes = data?['post_like'] ?? 0;
                      return Text(likes.toString());
                    }
                    return const Text('0');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: onComment,
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 28),
                const SizedBox(width: 4),
                StreamBuilder<int>(
                  stream: commentCountStream,
                  builder: (context, snapshot) {
                    return Text((snapshot.data ?? 0).toString());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.14159),
                child: const Icon(Icons.share_outlined, size: 28),
              ),
              const SizedBox(width: 4),
              Text(shares.toString()),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: onBookmark,
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
