import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../constants/constants.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(Prediction) onSelect;

  const MapSearchBar({
    super.key,
    required this.searchController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: searchController,
          googleAPIKey: googleApiKey,
          inputDecoration: const InputDecoration(
            hintText: 'Search location',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
          ),
          debounceTime: 800,
          countries: const ["th"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: onSelect,
          itemClick: onSelect,
          seperatedBuilder: const Divider(),
        ),
      ),
    );
  }
}
