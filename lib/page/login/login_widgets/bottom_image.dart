import 'package:flutter/material.dart';

class BottomImage extends StatelessWidget {
  const BottomImage({super.key});

  static const double _bottomImageHeight = 320.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: _bottomImageHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/screens/background2.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}
