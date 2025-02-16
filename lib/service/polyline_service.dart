import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripmaster/constants/constants.dart';

class PolylineService {
  final PolylinePoints polylinePoints = PolylinePoints();

  Future<List<LatLng>> getPolylinePoints(LatLng start, LatLng end) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      return result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } else {
      print("Failed to get polyline: ${result.errorMessage}");
      return [];
    }
  }

  Future<Set<Polyline>> updatePolylines(
      Map<String, dynamic> uploadTrips, int selectedDay) async {
    Set<Polyline> polylines = {};

    if (uploadTrips.isEmpty || !uploadTrips.containsKey('plan'))
      return polylines;

    List<dynamic> days = uploadTrips['plan'];
    List<dynamic> selectedDays = selectedDay == -1 ? days : [days[selectedDay]];

    for (var dayIndex = 0; dayIndex < selectedDays.length; dayIndex++) {
      List<dynamic> places = selectedDays[dayIndex]['places'];
      if (places.length < 2) continue;

      for (int i = 0; i < places.length - 1; i++) {
        LatLng start = LatLng(places[i]['location_position']['lat'],
            places[i]['location_position']['lng']);
        LatLng end = LatLng(places[i + 1]['location_position']['lat'],
            places[i + 1]['location_position']['lng']);

        bool isPassed =
            places[i]['passed'] == '1' && places[i + 1]['passed'] == '1';

        List<LatLng> route = await getPolylinePoints(start, end);

        String polylineId = "day_${dayIndex}_segment_${i}_to_${i + 1}";

        polylines.add(
          Polyline(
            polylineId: PolylineId(polylineId),
            color: isPassed
                ? const Color.fromARGB(255, 108, 131, 55)
                : Colors.grey,
            width: 5,
            points: route,
          ),
        );
      }
    }

    return polylines;
  }
}
