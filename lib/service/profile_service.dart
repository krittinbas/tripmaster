import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // แปลงข้อมูลดิบเป็น ProfileData
  Map<String, dynamic> _processUserData(
      String userId, Map<String, dynamic> data) {
    return {
      'user_id': userId,
      'user_title': (data['user_title']?.toString().isNotEmpty == true)
          ? data['user_title']
          : 'Profile Name',
      'username':
          data['username'] ?? '@${data['email']?.split('@')[0] ?? 'user'}',
      'email': data['email'] ?? '',
      'user_bio': data['user_bio'] ?? '',
      'profile_image': data['profile_image'] ?? '',
      'user_follower': data['user_follower'] ?? 0,
      'user_following': data['user_following'] ?? 0,
      'user_triptaken': data['user_triptaken'] ?? 0
    };
  }

  // ดึงข้อมูลผู้ใช้ปัจจุบัน
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (_auth.currentUser == null) {
        print('No user logged in');
        return null;
      }

      String userId = _auth.currentUser!.uid;
      print('Fetching profile for user: $userId');

      DocumentSnapshot userSnapshot =
          await _firestore.collection('User').doc(userId).get();

      print('User data exists: ${userSnapshot.exists}');
      if (userSnapshot.exists) {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
        print('Raw user data: $data');

        Map<String, dynamic> profileData = _processUserData(userId, data);
        print('Processed profile data: $profileData');
        return profileData;
      }

      print('No user document found');
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // ดึงข้อมูลของผู้ใช้อื่น
  Future<Map<String, dynamic>?> getOtherUserProfile(String userId) async {
    try {
      print('Fetching profile for other user: $userId');

      DocumentSnapshot userSnapshot =
          await _firestore.collection('User').doc(userId).get();

      print('Other user data exists: ${userSnapshot.exists}');
      if (userSnapshot.exists) {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
        print('Raw other user data: $data');

        Map<String, dynamic> profileData = _processUserData(userId, data);
        print('Processed other user profile data: $profileData');
        return profileData;
      }

      print('No other user document found');
      return null;
    } catch (e) {
      print('Error fetching other user profile: $e');
      return null;
    }
  }

  // เช็คว่าเป็นผู้ใช้ปัจจุบันหรือไม่
  Future<bool> isCurrentUser(String userId) async {
    final currentUser = _auth.currentUser;
    return currentUser?.uid == userId;
  }
}
