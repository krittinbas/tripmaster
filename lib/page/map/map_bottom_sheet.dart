import 'package:flutter/material.dart';

class MapBottomSheet extends StatelessWidget {
  final bool isVisible;
  final String? selectedPlaceName;
  final String? selectedPlaceAddress;
  final List<String> placeImages;
  final double bottomSheetHeight;
  final Function(bool) onVisibilityChanged;

  const MapBottomSheet({
    super.key,
    required this.isVisible,
    required this.selectedPlaceName,
    required this.selectedPlaceAddress,
    required this.placeImages,
    required this.bottomSheetHeight,
    required this.onVisibilityChanged,
  });

  Widget _buildDraggableBottomSheet() {
    if (!isVisible) return const SizedBox.shrink();

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent <= 0.15) {
          onVisibilityChanged(false);
        }
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.1,
        maxChildSize: 0.3,
        snap: true,
        snapSizes: const [0.3],
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHandleBar(),
                  _buildPlaceDetails(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandleBar() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPlaceDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedPlaceName ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A1F44),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            selectedPlaceAddress ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6E7787),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          _buildImageGallery(),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: placeImages.length,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(placeImages[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDraggableBottomSheet();
  }
}
