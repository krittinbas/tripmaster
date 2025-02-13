// lib/utils/register_validator.dart
import 'package:flutter/material.dart';
import 'package:tripmaster/models/register_form_data.dart';
import 'package:tripmaster/utils/bottom_sheet_utils.dart';
import 'package:tripmaster/constants/messages.dart';

class RegisterValidator {
  static bool validateForm(
    BuildContext context,
    RegisterFormData formData,
    bool isChecked,
  ) {
    if (formData.email.text.isEmpty) {
      _showValidationError(context, Messages.emailRequired);
      return false;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(formData.email.text)) {
      _showValidationError(context, Messages.invalidEmail);
      return false;
    }

    if (formData.username.text.isEmpty) {
      _showValidationError(context, Messages.usernameRequired);
      return false;
    }

    if (formData.phoneNumber.text.isEmpty) {
      _showValidationError(context, Messages.phoneNumberRequired);
      return false;
    }

    if (formData.password.text.isEmpty) {
      _showValidationError(context, Messages.passwordRequired);
      return false;
    }

    if (formData.password.text.length < 8) {
      _showValidationError(context, Messages.passwordTooShort);
      return false;
    }

    if (formData.password.text != formData.confirmPassword.text) {
      _showValidationError(context, Messages.passwordsNotMatch);
      return false;
    }

    if (!isChecked) {
      _showValidationError(context, Messages.termsAndConditions);
      return false;
    }

    return true;
  }

  static void _showValidationError(BuildContext context, String message) {
    showCustomBottomSheet(
      context: context,
      title: 'Validation Error',
      message: message,
      icon: Icons.warning,
      onOkPressed: () {},
    );
  }
}
