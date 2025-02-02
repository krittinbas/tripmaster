import 'package:flutter/material.dart';
import '../../../widgets/card/discover_card.dart';
import '../../../api/api_discover.dart';

class DiscoverSection extends StatelessWidget {
  final List<dynamic> places;
  final bool isLoading;
  final String? nextPageToken;
  final List<bool> isBookmarked;
  final Function({bool isPagination}) fetchFilteredData;
  final Function(dynamic place) onCardTap;
  final DiscoverApiService apiService; // Inject ApiService

  const DiscoverSection({
    required this.places,
    required this.isLoading,
    required this.nextPageToken,
    required this.isBookmarked,
    required this.fetchFilteredData,
    required this.onCardTap,
    required this.apiService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            nextPageToken != null) {
          fetchFilteredData(isPagination: true);
          return true;
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: places.length,
          itemBuilder: (context, index) {
            if (index >= places.length) return const SizedBox.shrink();

            final place = places[index];
            final String placeName = place['name'] ?? 'Unknown Place';

            String? photoReference;
            if (place['photos'] != null && place['photos'].isNotEmpty) {
              photoReference = place['photos'][0]['photo_reference'];
            }

            final String? photoUrl = photoReference != null
                ? apiService.getPhotoUrl(photoReference)
                : 'https://example.com/placeholder-image.jpg';

            return GestureDetector(
              onTap: () => onCardTap(place),
              child: DiscoverCard(
                locationName: placeName,
                rating:
                    place['rating'] != null ? place['rating'].toDouble() : 0.0,
                reviews: place['user_ratings_total'] ?? 0,
                imageUrl: photoUrl,
                isBookmarked: isBookmarked[index],
                index: index,
                onBookmarkPressed: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}
