import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../auth/auth_service_register.dart';
import '../widgets/bottom_sheet/bottom_sheets.dart';
import '../widgets/buttons/elevated_button.dart';
import '../widgets/text_field/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();
  bool isBusiness = false; // ตรวจสอบประเภทบัญชี
  bool isChecked = false; // ยอมรับเงื่อนไข
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // ฟิลด์สำหรับ business account
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // รับ argument เพื่อเช็คว่าเป็น Business Account หรือไม่
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['isBusiness'] != null) {
      isBusiness = args['isBusiness'];
    }
  }

  void _register() async {
    if (!isChecked) {
      showErrorBottomSheet(context, 'Please accept terms and conditions');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showErrorBottomSheet(context, 'Passwords do not match');
      return;
    }

    String? result;

    if (isBusiness) {
      result = await _authService.registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneNumberController.text,
        isBusiness: true,
        businessName: _businessNameController.text,
        businessType: _businessTypeController.text,
        businessAddress: _businessAddressController.text,
        taxId: _taxIdController.text,
      );
    } else {
      result = await _authService.registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneNumberController.text,
      );
    }

    if (result == null) {
      showRegistrationSuccessBottomSheet(context);
    } else {
      showErrorBottomSheet(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                  stops: [0.4, 1.0],
                ),
              ),
            ),
          ),
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
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    isBusiness
                        ? 'Create a Business Account'
                        : 'Create an Account',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLoginLink(),
                  const SizedBox(height: 40),
                  _buildInputFields(),
                  const SizedBox(height: 10),
                  _buildAgreementCheckbox(),
                  const SizedBox(height: 20),
                  EleButton(
                    title: 'Register',
                    onPressed: _register,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
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

  Widget _buildInputFields() {
    return Column(
      children: [
        CustomTextField(controller: _usernameController, hintText: 'Username'),
        const SizedBox(height: 10),
        CustomTextField(
            controller: _phoneNumberController, hintText: 'Phone number'),
        const SizedBox(height: 10),
        CustomTextField(
            controller: _emailController, hintText: 'Email address'),
        const SizedBox(height: 10),
        CustomTextField(
            controller: _passwordController,
            hintText: 'Password',
            isPassword: true),
        const SizedBox(height: 10),
        CustomTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm password',
            isPassword: true),
        if (isBusiness) ...[
          const SizedBox(height: 10),
          CustomTextField(
              controller: _businessNameController, hintText: 'Business Name'),
          const SizedBox(height: 10),
          CustomTextField(
              controller: _businessTypeController, hintText: 'Business Type'),
          const SizedBox(height: 10),
          CustomTextField(
              controller: _businessAddressController,
              hintText: 'Business Address'),
          const SizedBox(height: 10),
          CustomTextField(controller: _taxIdController, hintText: 'Tax ID'),
        ],
      ],
    );
  }

  Widget _buildAgreementCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = value!;
            });
          },
        ),
        const Expanded(
          child: Text("I agree to all terms & conditions"),
        ),
      ],
    );
  }
}
