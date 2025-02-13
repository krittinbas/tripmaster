import 'package:flutter/material.dart';

class MapActionButtons extends StatelessWidget {
  final bool isBottomSheetVisible;
  final double bottomSheetHeight;
  final VoidCallback onLocationPressed;

  const MapActionButtons({
    super.key,
    required this.isBottomSheetVisible,
    required this.bottomSheetHeight,
    required this.onLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: isBottomSheetVisible ? bottomSheetHeight + 20 : 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: onLocationPressed,
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.my_location,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // Upload function
            },
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.cloud_upload,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
