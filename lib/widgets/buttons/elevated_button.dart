import 'package:flutter/material.dart';

class EleButton extends StatelessWidget {
  final VoidCallback onPressed; // ฟังก์ชัน callback เมื่อกดปุ่ม
  final String title; // ข้อความในปุ่ม
  final Size? size; // ขนาดปุ่มที่เลือกได้

  const EleButton({
    Key? key,
    required this.onPressed, // ต้องกำหนดการทำงานเมื่อกดปุ่ม
    this.title = '', // ข้อความเริ่มต้นเป็นค่าว่าง
    this.size = const Size(216, 50), // ขนาดปุ่มค่าเริ่มต้น
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: size, // กำหนดขนาดปุ่มที่ผู้ใช้เลือกได้
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
