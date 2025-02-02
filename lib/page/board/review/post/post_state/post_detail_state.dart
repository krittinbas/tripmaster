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
  }

  void dispose() {
    commentController.dispose();
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
      }
    } catch (e) {
      print('Error updating like: $e');
    }
  }

  void updateCurrentImageIndex(int index) {
    currentImageIndex = index;
  }

  void toggleBookmark() {
    isBookmarked = !isBookmarked;
  }
}
