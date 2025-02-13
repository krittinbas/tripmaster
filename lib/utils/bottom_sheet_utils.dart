import 'package:flutter/material.dart';
import '../widgets/bottom_sheet/custom_bottom_sheet.dart';

void showCustomBottomSheet({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
  required VoidCallback onOkPressed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) => CustomBottomSheet(
      title: title,
      message: message,
      icon: icon,
      onOkPressed: () {
        Navigator.of(context).pop();
        onOkPressed();
      },
    ),
  );
}
