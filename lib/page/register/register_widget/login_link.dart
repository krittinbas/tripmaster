// lib/screens/register/widgets/login_link.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: "Already have an account? ",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          TextSpan(
            text: "Sign in",
            style: const TextStyle(
              color: Color(0xFF6B852F),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, '/login');
              },
          ),
        ],
      ),
    );
  }
}
