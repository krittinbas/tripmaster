import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected
              ? Colors.white
              : const Color(0xFF000D34), // เปลี่ยนสีของข้อความ
        ),
      ),
      selected: selected,
      onSelected: onSelected, // กระตุ้นการเปลี่ยนสถานะ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF000D34)),
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF000D34), // เปลี่ยนสีพื้นหลังเมื่อถูกเลือก
    );
  }
}

class RatingChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const RatingChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        children: [
          const Icon(Icons.star, color: Colors.yellow),
          Text(
            ' $label',
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(0xFF000D34), // เปลี่ยนสีของข้อความ
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected, // กระตุ้นการเปลี่ยนสถานะ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF000D34)),
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF000D34), // เปลี่ยนสีพื้นหลังเมื่อถูกเลือก
    );
  }
}
