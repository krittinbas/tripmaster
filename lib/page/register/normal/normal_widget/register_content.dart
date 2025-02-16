// lib/widgets/register/register_content.dart
import 'package:flutter/material.dart';
import 'package:tripmaster/models/register_form_data.dart';
import 'package:tripmaster/page/register/register_widget/login_link.dart';
import 'package:tripmaster/page/register/normal/normal_widget/register_form.dart';
import 'package:tripmaster/widgets/buttons/elevated_button.dart';

class RegisterContent extends StatelessWidget {
  final RegisterFormData formData;
  final bool isChecked;
  final Function(bool?) onCheckboxChanged;
  final VoidCallback onRegisterPressed;

  const RegisterContent({
    super.key,
    required this.formData,
    required this.isChecked,
    required this.onCheckboxChanged,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          _buildTitle(),
          const SizedBox(height: 8),
          const LoginLink(),
          const SizedBox(height: 40),
          RegisterForm(
            formData: formData,
            isChecked: isChecked,
            onCheckboxChanged: onCheckboxChanged,
          ),
          const SizedBox(height: 20),
          EleButton(
            title: 'Register',
            onPressed: onRegisterPressed,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      formData.isBusiness ? 'Create a Business Account' : 'Create an Account',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
