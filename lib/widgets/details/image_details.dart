import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageSliderWidget extends StatelessWidget {
  final List<String> imageAsset;

  const ImageSliderWidget({
    required this.imageAsset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 150,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
        ),
        items: imageAsset.map((url) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }).toList(),
      ),
    );
  }
}
