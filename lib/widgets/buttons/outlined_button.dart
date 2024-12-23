import 'package:flutter/material.dart';

class OutButton extends StatelessWidget {
  final VoidCallback onPressed; // ฟังก์ชัน callback เมื่อกดปุ่ม
  final String title; // ข้อความในปุ่ม
  final Size? size; // ขนาดปุ่มที่เลือกได้

  const OutButton({
    Key? key,
    required this.onPressed, // ต้องกำหนดการทำงานเมื่อกดปุ่ม
    this.title = '', // ข้อความเริ่มต้นเป็นค่าว่าง
    this.size = const Size(216, 50), // ขนาดปุ่มค่าเริ่มต้น
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: size, // กำหนดขนาดปุ่มที่ผู้ใช้เลือกได้
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // ขอบโค้งมน
        ),
        side: const BorderSide(color: Color(0xFF00164F)), // เส้นขอบปุ่ม
      ),
      child: Text(
        title.isNotEmpty ? title : '',
        style: const TextStyle(fontSize: 18, color: Color(0xFF00164F)),
      ),
    );
  }
}
