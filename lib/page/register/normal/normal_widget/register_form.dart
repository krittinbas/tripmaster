// lib/screens/register/widgets/register_form.dart

import 'package:flutter/material.dart';
import 'package:tripmaster/models/register_form_data.dart';
import '../../../../../widgets/text_field/custom_text_field.dart';

class RegisterForm extends StatelessWidget {
  final RegisterFormData formData;
  final bool isChecked;
  final ValueChanged<bool?> onCheckboxChanged;

  const RegisterForm({
    super.key,
    required this.formData,
    required this.isChecked,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBasicFields(),
        if (formData.isBusiness) _buildBusinessFields(),
        const SizedBox(height: 10),
        _buildAgreementCheckbox(),
      ],
    );
  }

  Widget _buildBasicFields() {
    return Column(
      children: [
        CustomTextField(controller: formData.username, hintText: 'Username'),
        const SizedBox(height: 10),
        CustomTextField(
            controller: formData.phoneNumber, hintText: 'Phone number'),
        const SizedBox(height: 10),
        CustomTextField(controller: formData.email, hintText: 'Email address'),
        const SizedBox(height: 10),
        CustomTextField(
            controller: formData.password,
            hintText: 'Password',
            isPassword: true),
        const SizedBox(height: 10),
        CustomTextField(
            controller: formData.confirmPassword,
            hintText: 'Confirm password',
            isPassword: true),
      ],
    );
  }

  Widget _buildBusinessFields() {
    return Column(
      children: [
        const SizedBox(height: 10),
        CustomTextField(
            controller: formData.businessName, hintText: 'Business Name'),
        const SizedBox(height: 10),
        CustomTextField(
            controller: formData.businessType, hintText: 'Business Type'),
        const SizedBox(height: 10),
        CustomTextField(
            controller: formData.businessAddress, hintText: 'Business Address'),
        const SizedBox(height: 10),
        CustomTextField(controller: formData.taxId, hintText: 'Tax ID'),
      ],
    );
  }

  Widget _buildAgreementCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: onCheckboxChanged,
        ),
        const Expanded(
          child: Text("I agree to all terms & conditions"),
        ),
      ],
    );
  }
}
