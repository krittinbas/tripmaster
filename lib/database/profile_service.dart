import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ดึงข้อมูลโปรไฟล์ผู้ใช้จาก Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      String userId = _auth.currentUser!.uid; // ดึง user ID จาก Firebase Auth

      // ดึงข้อมูลจาก collection 'User'
      DocumentSnapshot userSnapshot =
          await _firestore.collection('User').doc(userId).get();

      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>?;
      } else {
        return null; // ไม่มีข้อมูลใน database
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null; // เกิดข้อผิดพลาด
    }
  }

  // อัปเดตข้อมูลโปรไฟล์ผู้ใช้
  Future<void> updateUserProfile({
    required String name,
    required String bio,
  }) async {
    try {
      String userId = _auth.currentUser!.uid; // ดึง user ID จาก Firebase Auth

      await _firestore.collection('User').doc(userId).update({
        'username': name,
        'user_bio': bio,
      });
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // ดึงข้อมูลเกี่ยวกับสถิติของผู้ใช้
  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      String userId = _auth.currentUser!.uid;

      DocumentSnapshot userSnapshot =
          await _firestore.collection('User').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
        return {
          'followers': data['user_follower'] ?? 0,
          'following': data['user_following'] ?? 0,
          'trips': data['user_triptaken'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching user stats: $e');
      return null;
    }
  }
}
