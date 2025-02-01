import 'package:flutter/material.dart';
import 'package:tripmaster/screens/home_page.dart';
import 'package:tripmaster/screens/welcome_page.dart';
import 'package:tripmaster/screens/login_page.dart';
import 'package:tripmaster/screens/register_page.dart';
import 'package:tripmaster/screens/register_buisiness_page.dart';
import 'package:tripmaster/screens/forget_page.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String registerNormal = '/normal';
  static const String registerBusiness = '/business';
  static const String forget = '/forget';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomePage(),
    login: (context) => const LoginPage(),
    home: (context) => HomePage(),
    registerNormal: (context) => const RegisterPage(),
    registerBusiness: (context) => const RegisterBusinessPage(),
    forget: (context) => const ForgetPage(),
  };
}
