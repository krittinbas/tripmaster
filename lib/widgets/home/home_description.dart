// lib/pages/home/widgets/home_description.dart
import 'package:flutter/material.dart';
import '../../../constants/home_constants.dart';

class HomeDescription extends StatelessWidget {
  const HomeDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do',
      textAlign: TextAlign.center,
      style: HomeConstants.descriptionStyle,
    );
  }
}
