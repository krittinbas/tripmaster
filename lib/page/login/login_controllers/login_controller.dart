import 'package:flutter/material.dart';
import '../../../auth/auth_service_login.dart';

class LoginController {
  final AuthService _authService;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginController(this._authService);

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  Future<bool> handleSignIn() async {
    try {
      final user = await _authService.signIn(
        emailController.text,
        passwordController.text,
      );
      return user != null;
    } catch (e) {
      return false;
    }
  }

  void handleAccountSelection(BuildContext context, bool isBusiness) {
    final route = isBusiness ? '/business' : '/normal';
    Navigator.pushNamed(
      context,
      route,
      arguments: {'isBusiness': isBusiness},
    );
  }
}
