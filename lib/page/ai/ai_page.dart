import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Constants
class AiPageConstants {
  static const double searchBarRadius = 25.0;
  static const double contentPadding = 16.0;
  static const List<String> suggestions = [
    'Three Days in Chiang Mai: Culture, Cuisine, and Nature',
    'A 3-Day Adventure in Phuket',
    'One week in Krabi\'s Natural Wonders',
  ];
}

// Styles
class AiPageStyles {
  static const titleGradient = LinearGradient(
    colors: [
      Color(0xFFEE00FF), // Brighter pink
      Color(0xFFA200FF), // Deep purple
    ],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const titleStyle = TextStyle(
    fontSize: 20, // Reduced font size
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const suggestionHeaderStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static const suggestionItemStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    height: 1.5,
  );

  static final searchBarBorder = Border.all(
    color: Color(0xFFB900FF).withOpacity(0.3),
    width: 1.0,
  );
}

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AiPageConstants.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _HeaderSection(),
              SizedBox(height: 16),
              _SearchSection(),
              SizedBox(height: 20),
              _SuggestionsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ShaderMask(
        shaderCallback: (bounds) => AiPageStyles.titleGradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        blendMode: BlendMode.srcIn,
        child: const Text(
          'AI Trip Creator',
          style: AiPageStyles.titleStyle,
        ),
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AiPageConstants.searchBarRadius),
        border: AiPageStyles.searchBarBorder,
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              Icons.chevron_left,
              color: Colors.grey,
              size: 24,
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Placeholder text... ',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SuggestionsSection extends StatelessWidget {
  const _SuggestionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Suggestions',
              style: AiPageStyles.suggestionHeaderStyle,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.auto_awesome,
              size: 14,
              color: Colors.grey[600],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: AiPageConstants.suggestions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                AiPageConstants.suggestions[index],
                style: AiPageStyles.suggestionItemStyle,
              ),
            );
          },
        ),
      ],
    );
  }
}
