import 'package:flutter/material.dart';
import 'package:tripmaster/auth/auth_service_login.dart';
import '../../../widgets/text_field/custom_text_field.dart';
import '../../../widgets/buttons/elevated_button.dart';
import '../../../widgets/bottom_sheet/custom_bottom_sheet.dart';
import '../login_controllers/login_controller.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  static const double _horizontalPadding = 32.0;
  static const double _verticalSpacing = 10.0;

  @override
  Widget build(BuildContext context) {
    final controller = LoginController(AuthService());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        children: [
          CustomTextField(
            controller: controller.emailController,
            hintText: 'Email address',
          ),
          const SizedBox(height: _verticalSpacing),
          CustomTextField(
            controller: controller.passwordController,
            hintText: 'Password',
            isPassword: true,
          ),
          const SizedBox(height: _verticalSpacing),
          _buildForgetPasswordLink(context),
          const SizedBox(height: _verticalSpacing * 2),
          EleButton(
            title: 'Sign In',
            onPressed: () => _handleSignIn(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildForgetPasswordLink(BuildContext context) {
    return Align(
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
    );
  }

  Future<void> _handleSignIn(
      BuildContext context, LoginController controller) async {
    final success = await controller.handleSignIn();

    if (!context.mounted) return;

    if (success) {
      _showSuccessBottomSheet(context);
    } else {
      _showErrorBottomSheet(context);
    }
  }

  void _showSuccessBottomSheet(BuildContext context) {
    _showCustomBottomSheet(
      context: context,
      title: 'Success',
      message: 'Sign in successful! Welcome back.',
      icon: Icons.check_circle,
      onOkPressed: () {
        Navigator.of(context)
          ..pop()
          ..pushNamed('/home');
      },
    );
  }

  void _showErrorBottomSheet(BuildContext context) {
    _showCustomBottomSheet(
      context: context,
      title: 'Error',
      message: 'Invalid email or password. Please try again.',
      icon: Icons.error,
      onOkPressed: () => Navigator.pushNamed(context, '/login'),
    );
  }
}

void _showCustomBottomSheet({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
  required VoidCallback onOkPressed,
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
        onOkPressed();
      },
    ),
  );
}
