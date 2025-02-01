import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:tripmaster/consts.dart';

class PolylineService {
  final PolylinePoints polylinePoints = PolylinePoints();
  final List<List<dynamic>> uploadTrips;
  PolylineService(this.uploadTrips);
  List<LatLng> polylineCoordinates = [];

  Future<Set<Polyline>> polyline(int dayIndex) async {
    List<Polyline> polylineOptions = [];

    if (uploadTrips.isEmpty) return {};

    polylineOptions.clear();
    if (dayIndex == -1) {
      print('uploadTrips:$uploadTrips');
      for (var days in uploadTrips) {
        for (int i = 0; i < days.length - 1; i++) {
          List<Map<String, dynamic>> day =
              List<Map<String, dynamic>>.from(days);
          var start = day[i];
          var end = day[i + 1];

          if (int.parse(end['passed']) == 1) {
            for (int j = 0; j <= i; j++) {
              day[j]['passed'] = '1';
            }
          }

          int polylineWidth = 5;
          Color polylineColor = Colors.grey;
          if (int.parse(start['passed']) == 1 &&
              int.parse(end['passed']) == 1) {
            polylineColor = Colors.green;
            polylineWidth = 7;
          }

          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
            googleApiKey: googleApiKey,
            request: PolylineRequest(
              origin: PointLatLng(
                  start['location']['lat'], start['location']['lng']),
              destination:
                  PointLatLng(end['location']['lat'], end['location']['lng']),
              mode: TravelMode.driving,
            ),
          );

          List<LatLng> tempPolylineCoordinates = [];
          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              tempPolylineCoordinates
                  .add(LatLng(point.latitude, point.longitude));
            }
          }
          print(
              'tempPolylineCoordinates (from ${start['location']} to ${end['location']}):');
          for (var latLng in tempPolylineCoordinates) {
            print('Lat: ${latLng.latitude}, Lng: ${latLng.longitude}');
          }

          if (tempPolylineCoordinates.isNotEmpty) {
            polylineOptions.add(
              Polyline(
                polylineId: PolylineId('day_${day[i]}_line_$i'),
                color: polylineColor,
                points: tempPolylineCoordinates,
                width: polylineWidth,
              ),
            );
          }
        }
      }
    } else if (dayIndex < uploadTrips.length) {
      var dayLocations = uploadTrips[dayIndex];
      for (int i = 0; i < dayLocations.length - 1; i++) {
        var start = dayLocations[i];
        var end = dayLocations[i + 1];

        if (int.parse(end['passed']) == 1) {
          for (int j = 0; j <= i; j++) {
            dayLocations[j]['passed'] = '1';
          }
          print('check passed:$uploadTrips');
        }

        int polylineWidth = 5;
        Color polylineColor = Colors.grey;
        if (int.parse(start['passed']) == 1 && int.parse(end['passed']) == 1) {
          polylineColor = Colors.green;
          polylineWidth = 7;
        }

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: googleApiKey,
          request: PolylineRequest(
            origin:
                PointLatLng(start['location']['lat'], start['location']['lng']),
            destination:
                PointLatLng(end['location']['lat'], end['location']['lng']),
            mode: TravelMode.driving,
          ),
        );

        List<LatLng> tempPolylineCoordinates = [];
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            tempPolylineCoordinates
                .add(LatLng(point.latitude, point.longitude));
          }
        }

        if (tempPolylineCoordinates.isNotEmpty) {
          polylineOptions.add(
            Polyline(
              polylineId: PolylineId('$i'),
              color: polylineColor,
              points: tempPolylineCoordinates,
              width: polylineWidth,
            ),
          );
        }
      }
    }

    return polylineOptions.toSet();
  }
}
