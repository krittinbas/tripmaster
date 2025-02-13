// lib/screens/register/register_page.dart
import 'package:flutter/material.dart';
import 'package:tripmaster/auth/auth_service_register.dart';
import 'package:tripmaster/models/register_form_data.dart';
import 'package:tripmaster/page/register/normal/normal_widget/register_background.dart';
import 'package:tripmaster/page/register/normal/normal_widget/register_content.dart';
import 'package:tripmaster/validator/register_validator.dart';
import 'package:tripmaster/utils/bottom_sheet_utils.dart';
import 'package:tripmaster/constants/messages.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();
  final _formData = RegisterFormData();
  bool _isChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkBusinessAccount();
  }

  void _checkBusinessAccount() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['isBusiness'] != null) {
      _formData.isBusiness = args['isBusiness'];
    }
  }

  Future<void> _register() async {
    if (!RegisterValidator.validateForm(context, _formData, _isChecked)) return;

    final result = await _authService.registerUser(
      email: _formData.email.text,
      password: _formData.password.text,
      phoneNumber: _formData.phoneNumber.text,
      username: _formData.username.text,
      isBusiness: _formData.isBusiness,
      businessName: _formData.businessName.text,
      businessType: _formData.businessType.text,
      businessAddress: _formData.businessAddress.text,
      taxId: _formData.taxId.text,
    );

    if (!mounted) return;

    if (result == null) {
      _showRegistrationSuccess();
    } else {
      _showRegistrationError(result);
    }
  }

  void _showRegistrationSuccess() {
    showCustomBottomSheet(
      context: context,
      title: 'Registration Successful',
      message: Messages.registrationSuccess,
      icon: Icons.check_circle,
      onOkPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }

  void _showRegistrationError(String error) {
    showCustomBottomSheet(
      context: context,
      title: 'Registration Failed',
      message: error,
      icon: Icons.error,
      onOkPressed: () {},
    );
  }

  @override
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const RegisterBackground(),
          RegisterContent(
            formData: _formData,
            isChecked: _isChecked,
            onCheckboxChanged: (value) => setState(() => _isChecked = value!),
            onRegisterPressed: _register,
          ),
        ],
      ),
    );
  }
}
