import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowerService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> isFollowing(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final doc = await _firestore
        .collection('Follow')
        .where('follower_id', isEqualTo: currentUser.uid)
        .where('following_id', isEqualTo: targetUserId)
        .get();

    return doc.docs.isNotEmpty;
  }

  Future<void> followUser(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();

    final followRef = _firestore.collection('Follow').doc();
    batch.set(followRef, {
      'follower_id': currentUser.uid,
      'following_id': targetUserId,
      'created_at': FieldValue.serverTimestamp(),
    });

    final targetUserRef = _firestore.collection('User').doc(targetUserId);
    batch.update(targetUserRef, {
      'followers': FieldValue.increment(1),
    });

    final currentUserRef = _firestore.collection('User').doc(currentUser.uid);
    batch.update(currentUserRef, {
      'following': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unfollowUser(String targetUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();

    final followDoc = await _firestore
        .collection('Follow')
        .where('follower_id', isEqualTo: currentUser.uid)
        .where('following_id', isEqualTo: targetUserId)
        .get();

    if (followDoc.docs.isNotEmpty) {
      batch.delete(followDoc.docs.first.reference);

      final targetUserRef = _firestore.collection('User').doc(targetUserId);
      batch.update(targetUserRef, {
        'followers': FieldValue.increment(-1),
      });

      final currentUserRef = _firestore.collection('User').doc(currentUser.uid);
      batch.update(currentUserRef, {
        'following': FieldValue.increment(-1),
      });

      await batch.commit();
    }
  }
}
