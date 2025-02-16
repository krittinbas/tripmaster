import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../constants/constants.dart';

class SearchLocationPage extends StatefulWidget {
  final String postId;

  const SearchLocationPage({
    super.key,
    required this.postId,
  });

  @override
  State<SearchLocationPage> createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  bool _isLoading = false;
  final String apiKey = googleApiKey;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _onSearchChanged() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=${Uri.encodeFull(_searchController.text)}'
            '&components=country:th'
            '&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _predictions = data['predictions'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onLocationSelected(dynamic prediction) async {
    try {
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=${prediction['place_id']}'
            '&fields=geometry'
            '&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];

        // สร้าง document ID สำหรับ Location
        final locationId =
            FirebaseFirestore.instance.collection('Location').doc();

        // บันทึกข้อมูลลงใน Location collection
        await locationId.set({
          'location_id': locationId.id,
          'location_name': prediction['description'],
          'location_position': GeoPoint(
            location['lat'],
            location['lng'],
          ),
        });

        // ส่งข้อมูลกลับไปยังหน้าที่เรียก
        Navigator.pop(context, {
          'location_id': locationId.id,
          'location_name': prediction['description'],
          'location_position': GeoPoint(
            location['lat'],
            location['lng'],
          ),
        });
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get location details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            enableSuggestions: true,
            enabled: true,
            decoration: const InputDecoration(
              hintText: 'Search location',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    prediction['structured_formatting']['main_text'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    prediction['structured_formatting']['secondary_text'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _onLocationSelected(prediction),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
