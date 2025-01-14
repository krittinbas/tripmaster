import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String email,
    required String password,
    required String phoneNumber,
    bool isBusiness = false, // เพิ่ม parameter เพื่อตรวจสอบประเภทบัญชี
    String? businessName,
    String? businessType,
    String? businessAddress,
    String? taxId,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // บันทึกข้อมูลผู้ใช้ลงใน Firestore
      await _firestore.collection('User').doc(userCredential.user!.uid).set({
        'business_id':
            isBusiness ? userCredential.user!.uid : "", // ตรวจสอบประเภทบัญชี
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

      // ถ้าเป็น business account ให้เพิ่มข้อมูลใน collection 'Business'
      if (isBusiness) {
        await _firestore
            .collection('Business')
            .doc(userCredential.user!.uid)
            .set({
          'business_id': userCredential.user!.uid,
          'business_name': businessName,
          'business_type': businessType,
          'business_address': businessAddress,
          'tax_id': taxId,
        });
      }

      return null; // success
    } catch (e) {
      return e.toString(); // error message
    }
  }
}
