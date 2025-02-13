import 'package:flutter/material.dart';
import 'package:tripmaster/routes/app.dart';
import 'package:tripmaster/config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseConfig.initializeFirebase(); // โหลด Firebase ผ่าน Service
  runApp(const MyApp()); // เริ่มต้นแอป
}
