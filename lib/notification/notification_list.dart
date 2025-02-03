// file: lib/widgets/notification_list.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tripmaster/page/board/review/post/post_page/post_detail_page.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({Key? key}) : super(key: key);

  String _getNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('hh:mm a').format(dateTime).toLowerCase();
    }
  }

  String _getNotificationText(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'follow':
        return 'started following you.';
      case 'like':
        return 'liked your post.';
      case 'comment':
        return 'commented your post.';
      case 'share':
        return 'shared your post.';
      default:
        return '';
    }
  }

  Future<void> _markAllAsRead(
      BuildContext context, List<QueryDocumentSnapshot> notifications) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in notifications) {
      if (!(doc.data() as Map<String, dynamic>)['read']) {
        batch.update(doc.reference, {'read': true});
      }
    }

    await batch.commit();
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      List<QueryDocumentSnapshot> notifications) {
    final hasUnread = notifications
        .any((doc) => !(doc.data() as Map<String, dynamic>)['read']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if (hasUnread)
            TextButton(
              onPressed: () => _markAllAsRead(context, notifications),
              child: Text(
                'Mark all as read',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToPost(BuildContext context, Map<String, dynamic> data) async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('Post')
          .doc(data['post_id'])
          .get();

      if (!postDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post not found')),
        );
        return;
      }

      final postData = postDoc.data()!;

      // แปลง post_image เป็น List<String> อย่างปลอดภัย
      List<String> imageUrls = [];
      if (postData['post_image'] != null) {
        imageUrls = List<String>.from(postData['post_image']);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailPage(
            imageUrls: imageUrls,
            userId: postData['user_id'] ?? '',
            location: postData['location'] ?? '',
            topic: postData['post_title'] ?? '',
            description: postData['post_description'] ?? '',
            likes: postData['post_like'] ?? 0,
            comments: postData['comments'] ?? 0,
            shares: postData['post_share'] ?? 0,
            postId: postDoc.id,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to open post')),
      );
      print('Error navigating to post: $e');
    }
  }

  Widget _buildNotificationItem(
      BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = (data['created_at'] as Timestamp).toDate();
    final isRead = data['read'] ?? false;

    return Container(
      color: isRead ? null : Colors.grey.shade50,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: isRead ? Colors.grey.shade600 : Colors.black,
            ),
            children: [
              TextSpan(
                text: '@${data['sender_username']} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isRead ? Colors.grey.shade600 : Colors.black,
                ),
              ),
              TextSpan(text: _getNotificationText(data)),
            ],
          ),
        ),
        subtitle: Text(
          _getNotificationTime(createdAt),
          style: TextStyle(
            color: isRead ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete notification'),
                    onTap: () async {
                      await doc.reference.delete();
                      Navigator.pop(context);
                    },
                  ),
                  if (!isRead)
                    ListTile(
                      leading: const Icon(Icons.mark_email_read),
                      title: const Text('Mark as read'),
                      onTap: () async {
                        await doc.reference.update({'read': true});
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            );
          },
        ),
        onTap: () {
          // Mark as read
          if (!isRead) {
            doc.reference.update({'read': true});
          }

          // Navigate to post if notification is related to a post
          if (data['type'] != 'follow' && data['post_id'] != null) {
            _navigateToPost(context, data);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Notifications')
                  .where('recipient_id', isEqualTo: currentUser.uid)
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // แสดง loading ขณะโหลดข้อมูล
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // จัดการกรณี error
                if (snapshot.hasError) {
                  print('Error loading notifications: ${snapshot.error}');
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final notifications = snapshot.data?.docs ?? [];

                // แสดงข้อความเมื่อไม่มีการแจ้งเตือน
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // จัดกลุ่มการแจ้งเตือน
                final today = notifications.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final createdAt = (data['created_at'] as Timestamp).toDate();
                  return DateTime.now().difference(createdAt).inDays == 0;
                }).toList();

                final earlier = notifications.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final createdAt = (data['created_at'] as Timestamp).toDate();
                  return DateTime.now().difference(createdAt).inDays > 0;
                }).toList();

                // แสดงรายการแจ้งเตือน
                return ListView(
                  children: [
                    if (today.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Today', today),
                      ...today
                          .map((doc) => _buildNotificationItem(context, doc)),
                    ],
                    if (earlier.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Earlier', earlier),
                      ...earlier
                          .map((doc) => _buildNotificationItem(context, doc)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
