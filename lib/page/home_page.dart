// lib/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:tripmaster/page/board/board/board_page.dart';
import 'package:tripmaster/page/home_screen.dart';
import 'package:tripmaster/page/map/map_page.dart';
import 'package:tripmaster/page/profile/profile_page.dart';
import 'package:tripmaster/page/trip_page.dart';
import '../../routes/bottom_navigation.dart';

class HomePage extends StatefulWidget {
  final String? trip_id;

  final int? initialIndex;

  HomePage({
    super.key,
    this.trip_id,
    this.initialIndex,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }

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
        children: [
          const HomeScreen(),
          const TripPage(),
          MapPage(trip_id: widget.trip_id),
          const BoardPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
