// lib/pages/home/widgets/home_title.dart
import 'package:flutter/material.dart';
import '../../../constants/home_constants.dart';

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'Planning Your Next ',
        style: HomeConstants.titleStyle,
        children: <TextSpan>[
          TextSpan(
            text: '\nTrip Destination',
            style: HomeConstants.highlightedTitleStyle,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
