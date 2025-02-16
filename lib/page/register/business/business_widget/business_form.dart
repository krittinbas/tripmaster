// lib/screens/register/widgets/business_form.dart

import 'package:flutter/material.dart';
import 'package:tripmaster/models/business_register_data.dart';
import '../../../../../widgets/text_field/custom_text_field.dart';

class BusinessForm extends StatelessWidget {
  final BusinessRegisterData formData;
  final bool isChecked;
  final ValueChanged<bool?> onCheckboxChanged;
  final ValueChanged<String?> onBusinessTypeChanged;

  const BusinessForm({
    super.key,
    required this.formData,
    required this.isChecked,
    required this.onCheckboxChanged,
    required this.onBusinessTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBasicFields(),
        const SizedBox(height: 20),
        _buildBusinessDivider(),
        const SizedBox(height: 10),
        _buildBusinessFields(),
        const SizedBox(height: 20),
        _buildTermsCheckbox(),
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
          isPassword: true,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: formData.confirmPassword,
          hintText: 'Confirm password',
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildBusinessDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
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
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
      ],
    );
  }

  Widget _buildBusinessFields() {
    return Column(
      children: [
        CustomTextField(
          controller: formData.businessName,
          hintText: 'Business name',
        ),
        const SizedBox(height: 10),
        _buildBusinessTypeDropdown(),
        const SizedBox(height: 10),
        CustomTextField(
          controller: formData.businessAddress,
          hintText: 'Business address',
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: formData.taxId,
          hintText: 'Tax ID',
        ),
      ],
    );
  }

  Widget _buildBusinessTypeDropdown() {
    return DropdownButtonFormField<String>(
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
        DropdownMenuItem(value: 'Tour Operator', child: Text('Tour Operator')),
        DropdownMenuItem(value: 'Travel Agency', child: Text('Travel Agency')),
        DropdownMenuItem(value: 'Eco-Tourism', child: Text('Eco-Tourism')),
        DropdownMenuItem(
            value: 'Adventure Tours', child: Text('Adventure Tours')),
      ],
      onChanged: onBusinessTypeChanged,
      hint: const Text('Business type', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: onCheckboxChanged,
        ),
        Expanded(
          child: RichText(
            text: const TextSpan(
              text: 'I agree to all ',
              style: TextStyle(fontSize: 16, color: Color(0xFF00164F)),
              children: [
                TextSpan(
                  text: 'terms & conditions',
                  style: TextStyle(
                    color: Color(0xFF6B852F),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
