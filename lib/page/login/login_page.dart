import 'package:flutter/material.dart';
import 'package:tripmaster/page/login/login_widgets/background_gradient.dart';
import 'package:tripmaster/page/login/login_widgets/bottom_image.dart';
import 'package:tripmaster/page/login/login_widgets/login_content.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          BackgroundGradient(),
          BottomImage(),
          LoginContent(),
        ],
      ),
    );
  }
}
