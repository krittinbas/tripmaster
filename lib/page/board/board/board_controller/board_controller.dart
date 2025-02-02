// lib/screens/board_page/board/board_controller/board_controller.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripmaster/api/api_service.dart';
import 'package:tripmaster/api/api_discover.dart';
import 'package:tripmaster/constants/constants.dart';
import 'package:tripmaster/widgets/filter/filter_bottom_sheet.dart';
import 'dart:async';

class BoardController {
  final TabController tabController;
  final Function onStateChanged;

  BoardController({
    required this.tabController,
    required this.onStateChanged,
  });

  final ApiService _apiService = ApiService();
  final DiscoverApiService discoverApiService =
      DiscoverApiService(apiKey: googleApiKey);

  List<bool> isBookmarked = [];
  List<dynamic> places = [];
  bool isLoading = false;
  String? nextPageToken;

  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  Timer? _debounce;

  List<String> selectedCategories = ['Restaurants', 'Hotels', 'Tourist spot'];
  String selectedRating = '4.0+';

  void init() {
    fetchFilteredData();
    tabController.addListener(() {
      onStateChanged();
    });
  }

  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
  }

  Future<void> fetchFilteredData({bool isPagination = false}) async {
    if (isLoading) return;

    isLoading = true;
    if (!isPagination) {
      places = [];
      nextPageToken = null;
    }
    onStateChanged();

    await _apiService.fetchFilteredData(
      selectedCategories: selectedCategories,
      selectedRating: selectedRating,
      isPagination: isPagination,
      nextPageToken: nextPageToken,
      existingPlaces: places,
      onPlacesFetched: (fetchedPlaces) {
        places = fetchedPlaces;
        isBookmarked = List<bool>.filled(places.length, false);
        isLoading = false;
        onStateChanged();
      },
      onNextPageTokenFetched: (token) {
        nextPageToken = token;
        onStateChanged();
      },
    );
  }

  Future<void> searchLocations(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        searchResults = [];
        onStateChanged();
        return;
      }

      isLoading = true;
      onStateChanged();

      try {
        final lowercaseQuery = query.toLowerCase();
        final locationSnapshot =
            await FirebaseFirestore.instance.collection('Location').get();
        final matchingLocations = locationSnapshot.docs.where((doc) {
          final locationName =
              (doc.data()['location_name'] as String).toLowerCase();
          return locationName.contains(lowercaseQuery);
        }).toList();

        if (matchingLocations.isEmpty) {
          searchResults = [];
          isLoading = false;
          onStateChanged();
          return;
        }

        final locationIds = matchingLocations.map((doc) => doc.id).toList();
        final postSnapshot = await FirebaseFirestore.instance
            .collection('Post')
            .where('location_id', whereIn: locationIds)
            .get();

        final locationData = {
          for (var doc in matchingLocations)
            doc.id: doc.data()['location_name'] as String
        };

        searchResults = postSnapshot.docs.map((doc) {
          final postData = doc.data();
          return {
            ...postData,
            'post_id': doc.id,
            'location_name': locationData[postData['location_id']] ?? '',
          };
        }).toList();

        isLoading = false;
        onStateChanged();
      } catch (e) {
        print('Error searching locations: $e');
        isLoading = false;
        onStateChanged();
      }
    });
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return FilterBottomSheet(
          selectedCategories: selectedCategories,
          selectedRating: selectedRating,
          onApplyFilters: (categories, rating) {
            selectedCategories = categories;
            selectedRating = rating;
            onStateChanged();
            fetchFilteredData();
          },
        );
      },
    );
  }
}
