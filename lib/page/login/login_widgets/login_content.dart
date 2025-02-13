import 'package:flutter/material.dart';
import '../../../auth/auth_service_login.dart';
import '../login_controllers/login_controller.dart';
import 'login_form.dart';
import 'welcome_text.dart';
import 'register_link.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final LoginController _controller = LoginController(AuthService());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 2),
          WelcomeText(),
          SizedBox(height: 8),
          RegisterLink(),
          SizedBox(height: 20),
          LoginForm(),
          SizedBox(height: 20),
          Spacer(flex: 3),
        ],
      ),
    );
  }
}
