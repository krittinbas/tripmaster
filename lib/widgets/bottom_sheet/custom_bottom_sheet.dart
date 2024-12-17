import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title; // หัวข้อแจ้งเตือน (เช่น Error, Success)
  final String message; // ข้อความหลัก
  final VoidCallback onOkPressed;
  final IconData? icon; // ไอคอนแสดงสถานะ (เช่น Success หรือ Error)

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.onOkPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 0.30,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) // ไอคอนสถานะแจ้งเตือน
              Icon(icon, size: 50, color: const Color(0xFF00164F)),
            const SizedBox(height: 10),
            Text(
              title, // หัวข้อ (Error, Success)
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message, // ข้อความหลัก
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onOkPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(216, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: const Color(0xFF00164F),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
