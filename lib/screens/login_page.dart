import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../auth/auth_service_login.dart';
import '../widgets/text_field/custom_text_field.dart';
import '../widgets/buttons/elevated_button.dart';
import '../widgets/bottom_sheet/account_selection_bottom_sheet.dart';
import '../widgets/bottom_sheet/custom_bottom_sheet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String _errorMessage = '';

  Future<void> _signIn() async {
    try {
      final user = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return; // ตรวจสอบว่า Widget ยัง mounted อยู่หรือไม่

      if (user != null) {
        _showCustomBottomSheet(
          context: context, // ส่ง context ปัจจุบัน
          title: 'Success',
          message: 'Sign in successful! Welcome back.',
          icon: Icons.check_circle,
          onOkPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/home');
          },
        );
      }
    } catch (e) {
      if (!mounted) return; // ตรวจสอบว่า Widget ยัง mounted อยู่หรือไม่

      _showCustomBottomSheet(
        context: context,
        title: 'Error',
        message: 'Invalid email or password. Please try again.',
        icon: Icons.error,
        onOkPressed: () {
          Navigator.pushNamed(context, '/login');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color.fromARGB(255, 196, 228, 255),
                  ],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
          ),
          // Bottom Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/screens/background2.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRegisterLink(),
                const SizedBox(height: 20),
                _buildInputFields(),
                const SizedBox(height: 20),
                _buildSignInButton(),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Register Link
  Widget _buildRegisterLink() {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          TextSpan(
            text: 'Register now',
            style: const TextStyle(
              color: Color(0xFF6B852F),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _selectBottomSheet();
              },
          ),
        ],
      ),
    );
  }

  // Input Fields
  Widget _buildInputFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            hintText: 'Email address',
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: _passwordController,
            hintText: 'Password',
            isPassword: true,
          ),
          const SizedBox(height: 10),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/forget'),
              child: const Text(
                'Forget your password?',
                style: TextStyle(
                  color: Color(0xFF00164F),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sign In Button
  Widget _buildSignInButton() {
    return EleButton(
      title: 'Sign In', // เปลี่ยนข้อความในปุ่ม
      onPressed: () {
        _signIn(); // ฟังก์ชันที่ต้องการให้ทำงานเมื่อกดปุ่ม
      },
    );
  }

  void _selectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AccountSelectionBottomSheet(
        onNormalAccount: () {
          Navigator.pushNamed(
            context,
            '/normal', // ใช้ route เดียวกัน
            arguments: {'isBusiness': false}, // ส่งข้อมูล argument
          );
        },
        onBusinessAccount: () {
          Navigator.pushNamed(
            context,
            '/business', // ใช้ route เดียวกัน
            arguments: {'isBusiness': true}, // ส่งข้อมูล argument
          );
        },
      ),
    );
  }
}

void _showCustomBottomSheet({
  required BuildContext context, // รับ BuildContext มาด้วย
  required String title,
  required String message,
  required IconData icon,
  required VoidCallback onOkPressed,
}) {
  showModalBottomSheet(
    context: context, // ใช้ context ที่ส่งมา
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) => CustomBottomSheet(
      title: title,
      message: message,
      icon: icon,
      onOkPressed: () {
        Navigator.of(context).pop();
        onOkPressed();
      },
    ),
  );
}
