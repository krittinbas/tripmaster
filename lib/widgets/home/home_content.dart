// lib/pages/home/widgets/home_content.dart
import 'package:flutter/material.dart';
import '../../constants/home_constants.dart';
import 'home_title.dart';
import 'home_description.dart';
import 'home_buttons.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: HomeConstants.contentHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(HomeConstants.contentBorderRadius),
            topRight: Radius.circular(HomeConstants.contentBorderRadius),
          ),
        ),
        padding: HomeConstants.contentPadding,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HomeTitle(),
            SizedBox(height: HomeConstants.spacingBetweenTitleAndDescription),
            HomeDescription(),
            SizedBox(height: HomeConstants.spacingBeforeButtons),
            HomeButtons(),
          ],
        ),
      ),
    );
  }
}
