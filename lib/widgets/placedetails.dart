import 'package:flutter/material.dart';
import 'package:tripmaster/constants/constants.dart';

class PlaceDetails extends StatelessWidget {
  final dynamic place;

  const PlaceDetails({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    List<String> photoReferences = [];
    if (place['photos'] != null && place['photos'].isNotEmpty) {
      photoReferences = place['photos']
          .map<String>((photo) => photo['photo_reference'] as String)
          .toList()
          .take(1)
          .toList();
      print('Photo References: $photoReferences');
    } else {
      print('No photos available');
    }

    bool isCheckedpass = place['passed'] == '1';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            place['location_name'] ?? 'No Name',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(place['location_vicinity'] ?? 'No Address'),
          const SizedBox(height: 16),
          if (photoReferences.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photoReferences.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final photoReference = photoReferences[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$googleApiKey',
                      fit: BoxFit.cover,
                      width: 150,
                      height: 100,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                ),
                onPressed: isCheckedpass
                    ? null
                    : () {
                        place['passed'] = '1';
                        Navigator.pop(context, 'checked_in');
                      },
                child: const Text("check in",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
