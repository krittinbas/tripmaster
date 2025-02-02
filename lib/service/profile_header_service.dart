// lib/widgets/profile/profile_header_firebase.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripmaster/page/profile/profile_header/profile_header_state.dart';

class ProfileHeaderFirebase {
  final ProfileHeaderState state;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileHeaderFirebase(this.state);

  // เพิ่มฟังก์ชันใหม่สำหรับนับจำนวนโพสต์
  Stream<int> getUserPostCount(String userId) {
    return _firestore
        .collection('Post')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  void setupSubscriptions() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Listen to current user's following count
      final userSub = _firestore
          .collection('User')
          .doc(currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        if (state.mounted && snapshot.exists) {
          debugPrint(
              'Current following: ${snapshot.data()?['user_following']}');
          state.setState(() {
            state.currentFollowing = snapshot.data()?['user_following'] ?? 0;
          });
        }
      });
      state.userSubscription = userSub;

      // Listen to viewed profile's followers count
      final profileSub = _firestore
          .collection('User')
          .doc(state.widget.profileData.userId)
          .snapshots()
          .listen((snapshot) {
        if (state.mounted && snapshot.exists) {
          debugPrint('Current followers: ${snapshot.data()?['user_follower']}');
          state.setState(() {
            state.currentFollowers = snapshot.data()?['user_follower'] ?? 0;
          });
        }
      });
      state.profileSubscription = profileSub;
    }
  }

  void setupFollowListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !state.widget.isCurrentUser) {
      // Initial follow status check
      _firestore
          .collection('Follow')
          .where('follower_id', isEqualTo: currentUser.uid)
          .where('following_id', isEqualTo: state.widget.profileData.userId)
          .get()
          .then((snapshot) {
        if (state.mounted) {
          state.setState(() {
            state.isFollowing = snapshot.docs.isNotEmpty;
          });
        }
      });

      // Setup follow status listener
      final followSub = _firestore
          .collection('Follow')
          .where('follower_id', isEqualTo: currentUser.uid)
          .where('following_id', isEqualTo: state.widget.profileData.userId)
          .snapshots()
          .listen((snapshot) {
        if (state.mounted) {
          state.setState(() {
            state.isFollowing = snapshot.docs.isNotEmpty;
          });
        }
      });
      state.followSubscription = followSub;
    }
  }

  Future<void> handleFollow() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    state.setState(() {
      state.isLoading = true;
    });

    try {
      final batch = _firestore.batch();
      final followRef = _firestore.collection('Follow').doc();

      if (state.isFollowing) {
        await _handleUnfollow(currentUser, batch);
      } else {
        await _handleFollow(currentUser, batch, followRef);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error handling follow: $e');
    } finally {
      if (state.mounted) {
        state.setState(() {
          state.isLoading = false;
        });
      }
    }
  }

  Future<void> _handleUnfollow(User currentUser, WriteBatch batch) async {
    final querySnapshot = await _firestore
        .collection('Follow')
        .where('follower_id', isEqualTo: currentUser.uid)
        .where('following_id', isEqualTo: state.widget.profileData.userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      batch.delete(querySnapshot.docs.first.reference);

      final targetUserRef =
          _firestore.collection('User').doc(state.widget.profileData.userId);
      batch.update(targetUserRef, {'user_follower': FieldValue.increment(-1)});

      final currentUserRef = _firestore.collection('User').doc(currentUser.uid);
      batch
          .update(currentUserRef, {'user_following': FieldValue.increment(-1)});
    }
  }

  Future<void> _handleFollow(
      User currentUser, WriteBatch batch, DocumentReference followRef) async {
    batch.set(followRef, {
      'follow_id': followRef.id,
      'follower_id': currentUser.uid,
      'following_id': state.widget.profileData.userId,
      'created_at': FieldValue.serverTimestamp(),
    });

    final targetUserRef =
        _firestore.collection('User').doc(state.widget.profileData.userId);
    batch.update(targetUserRef, {'user_follower': FieldValue.increment(1)});

    final currentUserRef = _firestore.collection('User').doc(currentUser.uid);
    batch.update(currentUserRef, {'user_following': FieldValue.increment(1)});
  }
}
