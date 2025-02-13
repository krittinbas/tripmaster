import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/buttons/elevated_button.dart';

// Constants
class WelcomePageConstants {
  static const backgroundHeight = 320.0;
  static const gradientStops = [0.4, 1.0];
  static const gradientColors = [
    Colors.white,
    Color.fromARGB(255, 196, 228, 255),
  ];
}

// Styles
class WelcomePageStyles {
  static const titleBlackStyle = TextStyle(
    fontSize: 37,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const titleGreenStyle = TextStyle(
    fontSize: 37,
    fontWeight: FontWeight.bold,
    color: Color(0xFF6B852F),
  );

  static const subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return const Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _BackgroundGradient(),
          _BackgroundImage(),
          _ContentSection(),
        ],
      ),
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: WelcomePageConstants.gradientColors,
            stops: WelcomePageConstants.gradientStops,
          ),
        ),
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: WelcomePageConstants.backgroundHeight,
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

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            _buildTitle(),
            const SizedBox(height: 8),
            _buildSubtitle(),
            const Spacer(),
            _buildGetStartedButton(context),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Trip ',
            style: WelcomePageStyles.titleBlackStyle,
          ),
          TextSpan(
            text: 'Master',
            style: WelcomePageStyles.titleGreenStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do',
      textAlign: TextAlign.center,
      style: WelcomePageStyles.subtitleStyle,
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return EleButton(
      title: 'Get Started',
      onPressed: () => Navigator.pushNamed(context, '/login'),
    );
  }
}
