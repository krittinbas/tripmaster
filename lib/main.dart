import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core package
import 'package:tripmaster/screens/home_page.dart'; // Import ไฟล์ HomePage

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // สำหรับการใช้กับ async code ใน main()
  await Firebase.initializeApp(); // เรียกใช้การตั้งค่า Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
