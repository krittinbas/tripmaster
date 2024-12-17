import 'package:flutter/material.dart';

class OutButton extends StatelessWidget {
  final VoidCallback onPressed; // ฟังก์ชัน callback เมื่อกดปุ่ม
  final String title; // ข้อความในปุ่ม (สามารถเปลี่ยนได้)

  const OutButton({
    Key? key,
    required this.onPressed, // ต้องกำหนดการทำงานเมื่อกดปุ่ม
    this.title = '', // ข้อความเริ่มต้นเป็นค่าว่าง
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(216, 50), // ขนาดปุ่ม
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // ขอบโค้งมน
        ),
        backgroundColor: const Color(0xFF00164F), // สีพื้นหลังปุ่ม
      ),
      child: Text(
        title.isNotEmpty ? title : '',
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
