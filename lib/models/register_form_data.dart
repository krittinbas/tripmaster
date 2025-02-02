// lib/screens/register/models/register_form_data.dart

import 'package:flutter/material.dart';

class RegisterFormData {
  final username = TextEditingController();
  final phoneNumber = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // Business fields
  final businessName = TextEditingController();
  final businessType = TextEditingController();
  final businessAddress = TextEditingController();
  final taxId = TextEditingController();

  bool isBusiness = false;

  Map<String, String> get businessData => {
        'businessName': businessName.text,
        'businessType': businessType.text,
        'businessAddress': businessAddress.text,
        'taxId': taxId.text,
      };

  void dispose() {
    username.dispose();
    phoneNumber.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    businessName.dispose();
    businessType.dispose();
    businessAddress.dispose();
    taxId.dispose();
  }
}
