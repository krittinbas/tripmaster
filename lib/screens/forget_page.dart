import 'package:flutter/material.dart';
import '../auth/auth_service_forget.dart';
import '../widgets/bottom_sheet/custom_bottom_sheet.dart';
import '../widgets/buttons/elevated_button.dart';

class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  @override
  _ForgetPageState createState() => _ForgetPageState();
}

class _ForgetPageState extends State<ForgetPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.isEmpty) {
      _showBottomSheet(
        title: 'Error',
        message: 'Please enter your email address.',
        icon: Icons.error, // ไอคอนข้อผิดพลาด
      );
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(_emailController.text);
      _showBottomSheet(
        title: 'Success',
        message: 'Password reset email sent! Please check your inbox.',
        icon: Icons.check_circle, // ไอคอนสำเร็จ
        navigateToLogin: true,
      );
    } catch (e) {
      _showBottomSheet(
        title: 'Error',
        message: 'Please enter your email address.',
        icon: Icons.error, // ไอคอนข้อผิดพลาด
      );
    }
  }

  void _showBottomSheet({
    required String title,
    required String message,
    IconData? icon,
    bool navigateToLogin = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => CustomBottomSheet(
        title: title,
        message: message,
        icon: icon,
        onOkPressed: () {
          Navigator.of(context).pop(); // ปิด Bottom Sheet
          if (navigateToLogin) {
            Navigator.pushNamed(context, '/login');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            _buildFingerprintIcon(),
            const SizedBox(height: 20),
            const Text(
              'Forget password?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00164F),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your email for instructions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildEmailInput(),
            const SizedBox(height: 40),
            _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFingerprintIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF00164F),
      ),
      child: const Icon(Icons.fingerprint, size: 50, color: Colors.white),
    );
  }

  Widget _buildEmailInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Email address',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: 216,
      height: 47,
      child: EleButton(
        title: 'Reset Password', // เปลี่ยนข้อความในปุ่ม
        onPressed: () {
          _sendPasswordResetEmail(); // ฟังก์ชันที่ต้องการให้ทำงานเมื่อกดปุ่ม
        },
      ),
    );
  }
}
