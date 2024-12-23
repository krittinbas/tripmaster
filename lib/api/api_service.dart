import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  final String apiKey = 'AIzaSyARD6UUzTyxXJeKZrBLQX-cGFYrJ3vFcKo';

  Future<List<dynamic>> fetchFilteredData({
    required List<String> selectedCategories,
    required String selectedRating,
    bool isPagination = false,
    String? nextPageToken,
    required ValueChanged<List<dynamic>> onPlacesFetched,
    required ValueChanged<String?> onNextPageTokenFetched,
  }) async {
    final Map<String, String> categoryMapping = {
      'Restaurants': 'restaurant',
      'Hotels': 'lodging',
      'Tourist spot': 'tourist_attraction',
    };

    final selectedApiCategories = selectedCategories
        .map((category) => categoryMapping[category])
        .where((category) => category != null)
        .toList();

    List<dynamic> allPlaces = [];

    for (String? category in selectedApiCategories) {
      if (category == null) continue;

      final String url = nextPageToken != null && isPagination
          ? 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=$nextPageToken&key=$apiKey'
          : 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=13.736717,100.523186&radius=1500&type=$category&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final placesData = data['results'];
          nextPageToken = data['next_page_token'];

          allPlaces.addAll(placesData); // เพิ่มข้อมูลใน allPlaces
        } else {
          print('Failed to load data for category: $category');
        }
      } catch (error) {
        print('Error occurred for category $category: $error');
      }
    }

    double minRating = double.tryParse(selectedRating.replaceAll('+', '')) ?? 0;

    final filteredPlaces = allPlaces
        .where(
            (place) => place['rating'] != null && place['rating'] >= minRating)
        .toList();

    onPlacesFetched(filteredPlaces);
    onNextPageTokenFetched(nextPageToken);
    return filteredPlaces;
  }
}
