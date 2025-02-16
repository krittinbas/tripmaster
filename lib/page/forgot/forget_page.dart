import 'package:flutter/material.dart';
import 'package:tripmaster/page/forgot/forget_password_controller.dart';
import '../../widgets/bottom_sheet/custom_bottom_sheet.dart';
import '../../widgets/buttons/elevated_button.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final ForgetPasswordController _controller = ForgetPasswordController();
  final TextEditingController _emailController = TextEditingController();

  void _handleResetPassword() async {
    if (_emailController.text.isEmpty) {
      _showBottomSheet(
        title: 'Error',
        message: 'Please enter your email address.',
        icon: Icons.error,
      );
      return;
    }

    try {
      await _controller.sendPasswordResetEmail(_emailController.text);
      _showBottomSheet(
        title: 'Success',
        message: 'Password reset email sent! Please check your inbox.',
        icon: Icons.check_circle,
        navigateToLogin: true,
      );
    } catch (e) {
      _showBottomSheet(
        title: 'Error',
        message: 'Failed to send reset email. Please try again.',
        icon: Icons.error,
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
          Navigator.of(context).pop();
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          _buildFingerprintIcon(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 40),
          _buildEmailInput(),
          const SizedBox(height: 40),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      children: [
        Text(
          'Forget password?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00164F),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Enter your email for instructions',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
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
        title: 'Reset Password',
        onPressed: _handleResetPassword,
      ),
    );
  }
}
