import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.luggage),
          label: 'My Trip',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.border_all_rounded),
          label: 'Board',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF000D34), // สีของไอเท็มที่เลือก
      unselectedItemColor: Colors.grey, // สีของไอเท็มที่ไม่ได้เลือก
      backgroundColor: Colors.white, // ตั้งสีพื้นหลังเป็นสีขาว
      onTap: onTap,
      type: BottomNavigationBarType.fixed, // ป้องกันการเปลี่ยนสีโดยไม่ตั้งใจ
    );
  }
}
