// lib/pages/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:tripmaster/widgets/home/home_background.dart';
import 'package:tripmaster/widgets/home/home_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        HomeBackground(),
        HomeContent(),
      ],
    );
  }
}
