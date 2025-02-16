import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripmaster/constants/constants.dart';
import 'package:tripmaster/widgets/placedetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<LatLng> snapToRoad(LatLng position) async {
  final url =
      'https://roads.googleapis.com/v1/snapToRoads?path=${position.latitude},${position.longitude}&key=$googleApiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['snappedPoints'] != null && data['snappedPoints'].isNotEmpty) {
      double lat = data['snappedPoints'][0]['location']['latitude'];
      double lng = data['snappedPoints'][0]['location']['longitude'];
      return LatLng(lat, lng);
    }
  }
  return position;
}

Future<Set<Marker>> uploadMarkers(
    int dayIndex,
    Map<String, dynamic> upload_trips,
    BuildContext context,
    VoidCallback onCheckedIn) async {
  if (upload_trips.isEmpty) return {};

  List<Marker> markers = [];

  List<dynamic> selectedDays =
      dayIndex == -1 ? upload_trips['plan'] : [upload_trips['plan'][dayIndex]];

  for (var day in selectedDays) {
    for (var location in day['places']) {
      final markerColor = location['passed'] == '1'
          ? BitmapDescriptor.hueGreen
          : BitmapDescriptor.hueRed;

      LatLng markerPosition = LatLng(
        location['location_position']['lat'],
        location['location_position']['lng'],
      );
      print(
          "Original Position: ${markerPosition.latitude}, ${markerPosition.longitude}");
      LatLng snappedPosition = await snapToRoad(markerPosition);

      markers.add(
        Marker(
          markerId: MarkerId(location['location_name']),
          position: snappedPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
          onTap: () async {
            final result = await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return PlaceDetails(place: location);
              },
            );

            if (result == 'checked_in') {
              onCheckedIn();
            }
          },
        ),
      );
    }
  }

  return markers.toSet();
}
