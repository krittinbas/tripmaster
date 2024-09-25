import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core package
import 'package:tripmaster/auth/forget_page.dart';
import 'package:tripmaster/screens/home_page.dart'; // Import the HomePage
import 'package:tripmaster/auth/register_page.dart';
import 'package:tripmaster/auth/registerbuis_page.dart';
import 'package:tripmaster/screens/welcome_page.dart'; // Import WelcomePage
import 'package:tripmaster/auth/login_page.dart'; // Import LoginPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/normal': (context) => const RegisterPage(),
        '/business': (context) => const RegisterBuisPage(),
        '/forget': (context) => const ForgetPage(),
      },
    );
  }
}
