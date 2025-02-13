import 'package:flutter/material.dart';
import 'package:tripmaster/page/register/business/business_widget/background_widget.dart';
import 'package:tripmaster/validator/business_register_validator.dart';
import 'business_widget/business_form.dart';
import '../register_widget/login_link.dart';
import '../../../../../widgets/buttons/elevated_button.dart';
import '../../../models/business_register_data.dart';
import '../../../../../utils/bottom_sheet_utils.dart';
import '../../../../../constants/messages.dart';
import '../../../../../auth/auth_service_register.dart';

class RegisterBusinessPage extends StatefulWidget {
  const RegisterBusinessPage({super.key});

  @override
  _RegisterBusinessPageState createState() => _RegisterBusinessPageState();
}

class _RegisterBusinessPageState extends State<RegisterBusinessPage> {
  final _authService = AuthService();
  final _formData = BusinessRegisterData();
  bool _isChecked = false;

  @override
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!BusinessRegisterValidator.validateForm(context, _formData, _isChecked))
      return;

    String? result = await _authService.registerUser(
      email: _formData.email.text,
      password: _formData.password.text,
      phoneNumber: _formData.phoneNumber.text,
      username: _formData.username.text,
      isBusiness: true,
      businessName: _formData.businessName.text,
      businessType: _formData.businessType,
      businessAddress: _formData.businessAddress.text,
      taxId: _formData.taxId.text,
    );

    if (!mounted) return;
    _handleRegistrationResult(result);
  }

  void _handleRegistrationResult(String? result) {
    if (result == null) {
      showCustomBottomSheet(
        context: context,
        title: 'Registration Successful',
        message: Messages.registrationSuccess,
        icon: Icons.check_circle,
        onOkPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      );
    } else {
      showCustomBottomSheet(
        context: context,
        title: 'Registration Failed',
        message: result,
        icon: Icons.error,
        onOkPressed: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),
          _buildScrollableContent(),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildTitle(),
          const SizedBox(height: 8),
          const LoginLink(),
          const SizedBox(height: 20),
          BusinessForm(
            formData: _formData,
            isChecked: _isChecked,
            onCheckboxChanged: (value) => setState(() => _isChecked = value!),
            onBusinessTypeChanged: (value) =>
                setState(() => _formData.businessType = value),
          ),
          const SizedBox(height: 20),
          EleButton(
            title: 'Register',
            onPressed: _register,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Create a Business Account',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
