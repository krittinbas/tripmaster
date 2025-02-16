import 'package:flutter/material.dart';
import 'package:tripmaster/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome, // ใช้ route ชื่อ
      routes: AppRoutes.routes, // นำเข้า routes ทั้งหมดจาก AppRoutes
    );
  }
}
