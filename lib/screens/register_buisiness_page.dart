import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../auth/auth_service_register.dart';
import '../widgets/bottom_sheet/bottom_sheets.dart';
import '../widgets/text_field/custom_text_field.dart';

class RegisterBusinessPage extends StatefulWidget {
  const RegisterBusinessPage({super.key});

  @override
  _RegisterBusinessPageState createState() => _RegisterBusinessPageState();
}

class _RegisterBusinessPageState extends State<RegisterBusinessPage> {
  final _authService = AuthService();
  bool isChecked = false;

  // Controllers for the text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _taxIDController = TextEditingController();

  String? _businessType;

  Future<void> _register() async {
    if (!isChecked) {
      showErrorBottomSheet(context, 'Please accept terms and conditions');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showErrorBottomSheet(context, 'Passwords do not match');
      return;
    }

    String? result = await _authService.registerUser(
      email: _emailController.text,
      password: _passwordController.text,
      phoneNumber: _phoneController.text,
      isBusiness: true,
      businessName: _businessNameController.text,
      businessType: _businessType,
      businessAddress: _businessAddressController.text,
      taxId: _taxIDController.text,
    );

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
                  colors: [Colors.white, Color.fromARGB(255, 196, 228, 255)],
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
                  const Text(
                    'Create a Business Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
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
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                      controller: _usernameController, hintText: 'Username'),
                  const SizedBox(height: 10),
                  CustomTextField(
                      controller: _phoneController, hintText: 'Phone number'),
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
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.grey, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Business information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(color: Colors.grey, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                      controller: _businessNameController,
                      hintText: 'Business name'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: const [
                      DropdownMenuItem(
                          value: 'Tour Operator', child: Text('Tour Operator')),
                      DropdownMenuItem(
                          value: 'Travel Agency', child: Text('Travel Agency')),
                      DropdownMenuItem(
                          value: 'Eco-Tourism', child: Text('Eco-Tourism')),
                      DropdownMenuItem(
                          value: 'Adventure Tours',
                          child: Text('Adventure Tours')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _businessType = value;
                      });
                    },
                    hint: const Text('Business type',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                      controller: _businessAddressController,
                      hintText: 'Business address'),
                  const SizedBox(height: 10),
                  CustomTextField(
                      controller: _taxIDController, hintText: 'Tax ID'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to all ',
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF00164F)),
                            children: [
                              TextSpan(
                                text: 'terms & conditions',
                                style: const TextStyle(
                                    color: Color(0xFF6B852F), fontSize: 16),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print('Terms & Conditions tapped');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(216, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color(0xFF00164F),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
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
}
