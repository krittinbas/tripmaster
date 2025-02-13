import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../widgets/bottom_sheet/account_selection_bottom_sheet.dart';

class RegisterLink extends StatelessWidget {
  const RegisterLink({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          TextSpan(
            text: 'Register now',
            style: const TextStyle(
              color: Color(0xFF6B852F),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _showAccountSelectionBottomSheet(context),
          ),
        ],
      ),
    );
  }

  void _showAccountSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AccountSelectionBottomSheet(
        onNormalAccount: () => _handleAccountSelection(context, false),
        onBusinessAccount: () => _handleAccountSelection(context, true),
      ),
    );
  }

  void _handleAccountSelection(BuildContext context, bool isBusiness) {
    final route = isBusiness ? '/business' : '/normal';
    Navigator.pushNamed(
      context,
      route,
      arguments: {'isBusiness': isBusiness},
    );
  }
}
