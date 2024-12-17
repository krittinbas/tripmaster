import 'package:flutter/material.dart';

class AccountSelectionBottomSheet extends StatelessWidget {
  final VoidCallback onNormalAccount;
  final VoidCallback onBusinessAccount;

  const AccountSelectionBottomSheet({
    super.key,
    required this.onNormalAccount,
    required this.onBusinessAccount,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Indicator
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              'Select Account Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00164F),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onNormalAccount,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: const Color(0xFF00164F),
              ),
              child: const Text(
                'Normal Account',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onBusinessAccount,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF00164F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Business Account',
                style: TextStyle(fontSize: 18, color: Color(0xFF00164F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
