import 'package:flutter/material.dart';
import 'package:tripmaster/page/ai/ai_page.dart';
import 'package:tripmaster/page/home_page.dart';
import 'package:tripmaster/page/welcome_page.dart';
import 'package:tripmaster/page/login/login_page.dart';
import 'package:tripmaster/page/register/normal/register_page.dart';
import 'package:tripmaster/page/register/business/register_buisiness_page.dart';
import 'package:tripmaster/page/forgot/forget_page.dart';
import 'package:tripmaster/page/board/review/post/post_page/edit_post_screen.dart'; // เพิ่ม import

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String registerNormal = '/normal';
  static const String registerBusiness = '/business';
  static const String forget = '/forget';
  static const String editPost = '/edit-post'; // เพิ่ม route constant

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomePage(),
    login: (context) => const LoginPage(),
    home: (context) => HomePage(),
    registerNormal: (context) => const RegisterPage(),
    registerBusiness: (context) => const RegisterBusinessPage(),
    forget: (context) => const ForgetPasswordScreen(),
    editPost: (context) {
      // รับ arguments และส่งต่อให้ EditPostScreen
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return EditPostScreen(
        postId: args['postId'],
        postData: args['postData'],
      );
    },
  };
}
