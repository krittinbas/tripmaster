import 'package:flutter/material.dart';
import 'package:tripmaster/models/business_register_data.dart';
import '../constants/messages.dart';
import '../utils/bottom_sheet_utils.dart';

class BusinessRegisterValidator {
  static bool validateForm(
      BuildContext context, BusinessRegisterData formData, bool isChecked) {
    if (!_validateGeneralInfo(context, formData)) return false;
    if (!_validatePassword(context, formData)) return false;
    if (!_validateBusinessInfo(context, formData)) return false;
    if (!_validateTerms(context, isChecked)) return false;
    return true;
  }

  static bool _validateGeneralInfo(
      BuildContext context, BusinessRegisterData formData) {
    if (formData.email.text.isEmpty) {
      _showError(context, Messages.emailRequired);
      return false;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(formData.email.text)) {
      _showError(context, Messages.invalidEmail);
      return false;
    }

    if (formData.username.text.isEmpty) {
      _showError(context, Messages.usernameRequired);
      return false;
    }

    if (formData.phoneNumber.text.isEmpty) {
      _showError(context, Messages.phoneNumberRequired);
      return false;
    }

    return true;
  }

  static bool _validatePassword(
      BuildContext context, BusinessRegisterData formData) {
    if (formData.password.text.isEmpty) {
      _showError(context, Messages.passwordRequired);
      return false;
    }

    if (formData.password.text.length < 8) {
      _showError(context, Messages.passwordTooShort);
      return false;
    }

    if (formData.password.text != formData.confirmPassword.text) {
      _showError(context, Messages.passwordsNotMatch);
      return false;
    }

    return true;
  }

  static bool _validateBusinessInfo(
      BuildContext context, BusinessRegisterData formData) {
    if (formData.businessName.text.isEmpty) {
      _showError(context, Messages.businessNameRequired);
      return false;
    }

    if (formData.businessType?.isEmpty ?? true) {
      _showError(context, Messages.selectBusinessType);
      return false;
    }

    if (formData.businessAddress.text.isEmpty) {
      _showError(context, Messages.businessAddressRequired);
      return false;
    }

    if (formData.taxId.text.isEmpty) {
      _showError(context, Messages.taxIdRequired);
      return false;
    }

    if (!RegExp(r'^\d{13}$').hasMatch(formData.taxId.text)) {
      _showError(context, Messages.invalidTaxId);
      return false;
    }

    return true;
  }

  static bool _validateTerms(BuildContext context, bool isChecked) {
    if (!isChecked) {
      _showError(context, Messages.termsAndConditions);
      return false;
    }
    return true;
  }

  static void _showError(BuildContext context, String message) {
    showCustomBottomSheet(
      context: context,
      title: 'Validation Error',
      message: message,
      icon: Icons.warning,
      onOkPressed: () {},
    );
  }
}
