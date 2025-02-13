import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class FirebaseConfig {
  // ฟังก์ชันสำหรับตั้งค่า Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(); // ตั้งค่า Firebase

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider('your-site-key'),
    );
  }
}
