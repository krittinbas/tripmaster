// lib/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:tripmaster/page/board/board/board_page.dart';
import 'package:tripmaster/page/home_screen.dart';
import 'package:tripmaster/page/map/map_page.dart';
import 'package:tripmaster/page/profile/profile_page.dart';
import 'package:tripmaster/page/trip_page.dart';
import '../../routes/bottom_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(),
          TripPage(),
          MapPage(),
          BoardPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
