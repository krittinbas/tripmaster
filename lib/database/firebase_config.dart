import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  // ฟังก์ชันสำหรับตั้งค่า Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(); // ตั้งค่า Firebase
  }
}
