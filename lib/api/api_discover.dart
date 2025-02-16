import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';

class DiscoverApiService {
  String apiKey = googleApiKey;
  String apiKeys = 'googleApiKey';
  DiscoverApiService({required this.apiKey});

  Future<Map<String, dynamic>> fetchPlaces(
      {required String nextPageToken}) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=$nextPageToken&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load places');
    }
  }

  String getPhotoUrl(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
  }
}
