// lib/pages/home/widgets/home_buttons.dart
import 'package:flutter/material.dart';
import 'package:tripmaster/page/tripcreator_page.dart';
import '../../../constants/home_constants.dart';
import '../../../widgets/buttons/elevated_button.dart';
import '../../../widgets/buttons/outlined_button.dart';

class HomeButtons extends StatelessWidget {
  const HomeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EleButton(
            title: 'Create Trip',
            size: HomeConstants.mainButtonSize,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TripCreatorPage()),
              );
            }),
        const SizedBox(height: HomeConstants.spacingBetweenButtons),
        OutButton(
          title: 'Join Tour',
          size: HomeConstants.mainButtonSize,
          onPressed: () {
            debugPrint('Join Tour');
          },
        ),
      ],
    );
  }
}
