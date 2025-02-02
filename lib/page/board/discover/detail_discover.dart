import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailPage extends StatefulWidget {
  final dynamic place;

  const DetailPage({super.key, required this.place});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? placeDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaceDetails(widget.place['place_id']);
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    const apiKey =
        'AIzaSyBBQyIUAqI34N7i1TNPYEmBXGOAMyOA-P8'; // Replace with your actual API key
    const apiKeys = 'asd';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number,website&key=$apiKeys',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          placeDetails = data['result'];
          isLoading = false;
        });
      } else {
        throw 'Failed to load place details';
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching place details: $e');
    }
  }

  String getOpeningStatus(dynamic openingHours) {
    if (openingHours == null) return 'No opening hours available';

    if (openingHours['open_now'] == true) {
      return 'Open Now';
    } else {
      return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display multiple images
                    if (place['photos'] != null && place['photos'].isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: PageView.builder(
                          itemCount: place['photos'].length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][index]['photo_reference']}&key=AIzaSyBBQyIUAqI34N7i1TNPYEmBXGOAMyOA-P8s',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: Text('No Image Available')),
                      ),

                    // Display details
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              place['name'] ?? 'Unknown Place',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Rating
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                    '${place['rating'] ?? 'N/A'} (${place['user_ratings_total'] ?? 0} reviews)'),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Address
                            if (place['vicinity'] != null)
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(place['vicinity'])),
                                ],
                              ),
                            const SizedBox(height: 16),

                            // Opening hours
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(getOpeningStatus(place['opening_hours'])),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Website
                            if (placeDetails?['website'] != null)
                              Row(
                                children: [
                                  const Icon(Icons.web, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () async {
                                        final url = placeDetails!['website'];
                                        if (await canLaunchUrl(
                                            Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url));
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        placeDetails!['website'],
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow:
                                            TextOverflow.ellipsis, // ตัดข้อความ
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              const Row(
                                children: [
                                  Icon(Icons.web, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('No website available'),
                                ],
                              ),
                            const SizedBox(height: 16),

                            // Phone number
                            if (placeDetails?['formatted_phone_number'] != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone, color: Colors.purple),
                                  const SizedBox(width: 8),
                                  Text(placeDetails!['formatted_phone_number']),
                                ],
                              )
                            else
                              const Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.purple),
                                  SizedBox(width: 8),
                                  Text('No phone number available'),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement map functionality here
                          },
                          icon: const Icon(Icons.map, color: Color(0xFF000D34)),
                          label: const Text(
                            'Map',
                            style: TextStyle(color: Color(0xFF000D34)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement share functionality here
                          },
                          icon:
                              const Icon(Icons.share, color: Color(0xFF000D34)),
                          label: const Text(
                            'Share',
                            style: TextStyle(color: Color(0xFF000D34)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement bookmark functionality here
                          },
                          icon: const Icon(Icons.bookmark,
                              color: Color(0xFF000D34)),
                          label: const Text(
                            'Bookmark',
                            style: TextStyle(color: Color(0xFF000D34)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
