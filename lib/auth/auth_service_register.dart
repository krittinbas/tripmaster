import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // บันทึกข้อมูลผู้ใช้ลงใน Firestore
      await _firestore.collection('User').doc(userCredential.user!.uid).set({
        'business_id': "",
        'email': email,
        'password': password, // ไม่ควรเก็บ plain text password
        'phonenumber': phoneNumber,
        'user_bio': "",
        'user_follower': 0,
        'user_following': 0,
        'user_id': userCredential.user!.uid,
        'user_title': "",
        'user_triptaken': 0,
        'username': email,
      });

      return null; // success
    } catch (e) {
      return e.toString(); // error message
    }
  }
}
