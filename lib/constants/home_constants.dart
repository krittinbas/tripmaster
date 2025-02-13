// lib/constants/home_constants.dart
import 'package:flutter/material.dart';

class HomeConstants {
  // Layout constants
  static const double contentHeight = 540;
  static const double contentBorderRadius = 30;
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 30,
  );

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle highlightedTitleStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Color(0xFF6B852F),
  );

  static const TextStyle descriptionStyle = TextStyle(
    color: Colors.grey,
    fontSize: 16,
  );

  // Button sizes
  static const Size mainButtonSize = Size(250, 50);

  // Spacing
  static const double spacingBetweenTitleAndDescription = 10;
  static const double spacingBeforeButtons = 210;
  static const double spacingBetweenButtons = 10;
}
