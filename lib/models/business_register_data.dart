// lib/screens/register/models/business_register_data.dart

import 'package:flutter/material.dart';

class BusinessRegisterData {
  final username = TextEditingController();
  final phoneNumber = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // Business fields
  final businessName = TextEditingController();
  final businessAddress = TextEditingController();
  final taxId = TextEditingController();
  String? businessType;

  void dispose() {
    username.dispose();
    phoneNumber.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    businessName.dispose();
    businessAddress.dispose();
    taxId.dispose();
  }

  Map<String, String> getBusinessData() {
    return {
      'businessName': businessName.text,
      'businessType': businessType ?? '',
      'businessAddress': businessAddress.text,
      'taxId': taxId.text,
    };
  }
}
