import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/constants.dart';

class ApiService {
  final String apiKey = 'YOUR_GOOGLE_API_KEY';
  final String apiKeys = googleApiKey;
  bool isLoading = false;

  // ฟังก์ชันตรวจสอบและขอสิทธิ์การเข้าถึงตำแหน่ง
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่า location services เปิดอยู่หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    // ตรวจสอบสิทธิ์การเข้าถึงตำแหน่ง
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return false;
    }

    return true;
  }

  // ฟังก์ชันดึงตำแหน่งปัจจุบัน
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // ฟังก์ชันหลักสำหรับดึงข้อมูลสถานที่
  Future<List<dynamic>> fetchFilteredData({
    required List<String> selectedCategories,
    required String selectedRating,
    bool isPagination = false,
    String? nextPageToken,
    required ValueChanged<List<dynamic>> onPlacesFetched,
    required ValueChanged<String?> onNextPageTokenFetched,
    required List<dynamic> existingPlaces,
  }) async {
    if (isLoading) return existingPlaces;
    isLoading = true;

    try {
      // ดึงตำแหน่งปัจจุบัน
      Position? currentPosition = await getCurrentLocation();
      String location = currentPosition != null
          ? '${currentPosition.latitude},${currentPosition.longitude}'
          : '13.117313,100.922103'; // ตำแหน่งเริ่มต้น

      final Map<String, List<String>> categoryMapping = {
        'Restaurants': ['restaurant', 'cafe', 'bakery', 'meal_takeaway', 'bar'],
        'Hotels': ['lodging', 'guest_house', 'hostel', 'motel', 'resort'],
        'Tourist spot': [
          'tourist_attraction',
          'museum',
          'park',
          'beach',
          'zoo',
          'aquarium',
          'amusement_park',
          'landmark',
          'art_gallery',
          'point_of_interest'
        ],
      };

      List<dynamic> allPlaces = List.from(existingPlaces);
      Set<String> uniquePlaceIds =
          allPlaces.map((place) => place['place_id'] as String).toSet();

      // ดึงข้อมูลสำหรับแต่ละหมวดหมู่
      for (String category in selectedCategories) {
        final apiCategories = categoryMapping[category] ?? [];
        for (String apiCategory in apiCategories) {
          final String url = nextPageToken != null && isPagination
              ? 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=$nextPageToken&key=$apiKey'
              : 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=10000&type=$apiCategory&key=$apiKey';

          try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data['status'] == 'OK') {
                final placesData = data['results'] as List;
                nextPageToken = data['next_page_token'];

                // เพิ่มสถานที่ที่ไม่ซ้ำกัน
                for (var place in placesData) {
                  if (!uniquePlaceIds.contains(place['place_id'])) {
                    uniquePlaceIds.add(place['place_id']);
                    allPlaces.add(place);
                  }
                }
              } else {
                print('API error: ${data['status']}');
              }
            } else {
              print('Failed to load data. Status code: ${response.statusCode}');
            }
          } catch (error) {
            print('Error fetching places for category $apiCategory: $error');
          }
        }
      }

      // กรองตามคะแนน
      double minRating =
          double.tryParse(selectedRating.replaceAll('+', '')) ?? 0;
      final filteredPlaces = allPlaces.where((place) {
        final rating = place['rating'] ?? 0.0;
        final userRatings = place['user_ratings_total'] ?? 0;
        return rating >= minRating && userRatings > 10;
      }).toList();

      // เรียงลำดับตามคะแนน (จากมากไปน้อย)
      filteredPlaces.sort((a, b) {
        final ratingA = a['rating'] ?? 0.0;
        final ratingB = b['rating'] ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      onPlacesFetched(filteredPlaces);
      onNextPageTokenFetched(nextPageToken);

      return filteredPlaces;
    } catch (e) {
      print('Error in fetchFilteredData: $e');
      return existingPlaces;
    } finally {
      isLoading = false;
    }
  }

  // ฟังก์ชันดึงรายละเอียดของสถานที่
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number,website,opening_hours,reviews&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return {};
    } catch (e) {
      print('Error fetching place details: $e');
      return {};
    }
  }

  // ฟังก์ชันสร้าง URL สำหรับรูปภาพ
  String getPhotoUrl(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
  }

  // ฟังก์ชันค้นหาสถานที่
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      Position? currentPosition = await getCurrentLocation();
      String location = currentPosition != null
          ? '${currentPosition.latitude},${currentPosition.longitude}'
          : '13.117313,100.922103';

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=$location&radius=50000&key=$apiKey');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        }
      }
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
}
