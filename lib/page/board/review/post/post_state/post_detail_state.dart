// file: lib/page/board/review/post/post_state/post_detail_state.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../post_page/post_detail_page.dart';

class PostDetailStateManager {
  final PostDetailPage widget;
  int currentImageIndex = 0;
  bool isLiked = false;
  bool isBookmarked = false;
  final TextEditingController commentController = TextEditingController();

  PostDetailStateManager(this.widget);

  void initialize() {
    _checkIfLiked();
    _checkIfBookmarked();
  }

  void dispose() {
    commentController.dispose();
  }

  // ฟังก์ชันสร้างการแจ้งเตือนเมื่อกดไลค์
  Future<void> _createLikeNotification() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // ไม่สร้างการแจ้งเตือนถ้าไลค์โพสต์ตัวเอง
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
        'type': 'like',
        'post_id': widget.postId,
        'created_at': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      print('Error creating like notification: $e');
    }
  }

  // Stream ข้อมูลผู้ใช้
  Stream<DocumentSnapshot> get userDataStream {
    return FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userId)
        .snapshots();
  }

  // Stream ข้อมูลโพสต์
  Stream<DocumentSnapshot> get postStream {
    return FirebaseFirestore.instance
        .collection('Post')
        .doc(widget.postId)
        .snapshots();
  }

  // Stream จำนวนความคิดเห็น
  Stream<int> get commentCountStream {
    return FirebaseFirestore.instance
        .collection('Comment')
        .where('post_id', isEqualTo: widget.postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ตรวจสอบสถานะการไลค์
  Future<void> _checkIfLiked() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Like')
            .where('post_id', isEqualTo: widget.postId)
            .where('user_id', isEqualTo: currentUser.uid)
            .get();

        isLiked = querySnapshot.docs.isNotEmpty;
      } catch (e) {
        print('Error checking like status: $e');
      }
    }
  }

  // ตรวจสอบสถานะการบุ๊คมาร์ค
  Future<void> _checkIfBookmarked() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Bookmark')
            .where('post_id', isEqualTo: widget.postId)
            .where('user_id', isEqualTo: currentUser.uid)
            .get();

        isBookmarked = querySnapshot.docs.isNotEmpty;
      } catch (e) {
        print('Error checking bookmark status: $e');
      }
    }
  }

  // จัดการการกดไลค์
  Future<void> handleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Like')
          .where('post_id', isEqualTo: widget.postId)
          .where('user_id', isEqualTo: currentUser.uid)
          .get();

      final postRef =
          FirebaseFirestore.instance.collection('Post').doc(widget.postId);

      if (querySnapshot.docs.isNotEmpty) {
        // ถ้ามีการกดไลค์แล้ว ให้ลบออก
        await querySnapshot.docs.first.reference.delete();
        await postRef.update({'post_like': FieldValue.increment(-1)});
        isLiked = false;
      } else {
        // ถ้ายังไม่มีการกดไลค์ ให้เพิ่มเข้าไป
        final likeRef = FirebaseFirestore.instance.collection('Like').doc();
        await likeRef.set({
          'post_id': widget.postId,
          'user_id': currentUser.uid,
          'like_id': likeRef.id,
          'created_at': FieldValue.serverTimestamp()
        });

        await postRef.update({'post_like': FieldValue.increment(1)});
        isLiked = true;

        // สร้างการแจ้งเตือนเมื่อกดไลค์
        await _createLikeNotification();
      }
    } catch (e) {
      print('Error updating like: $e');
    }
  }

  // จัดการการบุ๊คมาร์ค
  Future<void> toggleBookmark() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Bookmark')
          .where('post_id', isEqualTo: widget.postId)
          .where('user_id', isEqualTo: currentUser.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // ถ้ามีการบุ๊คมาร์คแล้ว ให้ลบออก
        await querySnapshot.docs.first.reference.delete();
        isBookmarked = false;
      } else {
        // ถ้ายังไม่มีการบุ๊คมาร์ค ให้เพิ่มเข้าไป
        final bookmarkRef =
            FirebaseFirestore.instance.collection('Bookmark').doc();
        await bookmarkRef.set({
          'post_id': widget.postId,
          'user_id': currentUser.uid,
          'bookmark_id': bookmarkRef.id,
          'created_at': FieldValue.serverTimestamp()
        });
        isBookmarked = true;
      }
    } catch (e) {
      print('Error updating bookmark: $e');
    }
  }

  void updateCurrentImageIndex(int index) {
    currentImageIndex = index;
  }

  // อัพเดตจำนวนคอมเมนต์
  Future<void> refreshCommentCount() async {
    try {
      final commentCount = await FirebaseFirestore.instance
          .collection('Comment')
          .where('post_id', isEqualTo: widget.postId)
          .get()
          .then((snapshot) => snapshot.docs.length);

      await FirebaseFirestore.instance
          .collection('Post')
          .doc(widget.postId)
          .update({'comment_count': commentCount});
    } catch (e) {
      print('Error refreshing comment count: $e');
    }
  }
}
