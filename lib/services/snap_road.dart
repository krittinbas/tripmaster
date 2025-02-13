import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tripmaster/constants/constants.dart';
import 'package:tripmaster/widgets/placedetails.dart';

class SnapToRoadService {
  final List<List<dynamic>>? uploadTrips;

  SnapToRoadService(this.uploadTrips);

  Future<LatLng?> snapToRoads(LatLng originalLocation, String apiKey) async {
    final url =
        'https://roads.googleapis.com/v1/snapToRoads?path=${originalLocation.latitude},${originalLocation.longitude}&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['snappedPoints'] != null && data['snappedPoints'].isNotEmpty) {
        final snappedLocation = data['snappedPoints'][0]['location'];
        return LatLng(
          snappedLocation['latitude'],
          snappedLocation['longitude'],
        );
      }
    }
    return null;
  }

  Set<Marker> uploadMarkers(int dayIndex, BuildContext context) {
    if (uploadTrips == null || uploadTrips!.isEmpty) return {};

    List<Marker> markers = [];
    if (dayIndex == -1) {
      // รวม Marker จากทุกวัน
      for (var day in uploadTrips!) {
        for (var location in day) {
          final markerColor = location['passed'] == '1'
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed;

          markers.add(
            Marker(
              markerId: MarkerId(location['name']),
              position: LatLng(
                location['location']['lat'],
                location['location']['lng'],
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
              infoWindow: InfoWindow(
                title: location['name'],
                snippet: location['vicinity'],
              ),
              onTap: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return PlaceDetails(place: location);
                  },
                );
                print('checked_in : $result');
                if (result == 'checked_in') {}
              },
            ),
          );
        }
      }
    } else if (dayIndex < uploadTrips!.length) {
      // แสดง Marker ของวันเดียว
      var dayLocations = uploadTrips![dayIndex];

      // 1. ตรวจสอบว่ามีสถานที่จากวันก่อนหน้า
      if (dayIndex > 0) {
        // เอาตำแหน่งสถานที่สุดท้ายจากวันก่อนหน้า
        var previousDayLocations = uploadTrips![dayIndex - 1];
        var lastLocationOfPreviousDay = previousDayLocations.last;

        // 2. แสดง Marker ของสถานที่สุดท้ายจากวันก่อนหน้า
        markers.add(
          Marker(
            markerId: MarkerId(lastLocationOfPreviousDay['name'] + '_previous'),
            position: LatLng(
              lastLocationOfPreviousDay['location']['lat'],
              lastLocationOfPreviousDay['location']['lng'],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor
                .hueYellow), // สีสำหรับ Marker ของสถานที่สุดท้าย
            infoWindow: InfoWindow(
              title: lastLocationOfPreviousDay['name'],
              snippet: lastLocationOfPreviousDay['vicinity'],
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                builder: (BuildContext context) {
                  return PlaceDetails(place: lastLocationOfPreviousDay);
                },
              );
            },
          ),
        );
      }

      // 3. แสดง Marker ของสถานที่ในวันปัจจุบัน
      for (var location in dayLocations) {
        final markerColor = location['passed'] == '1'
            ? BitmapDescriptor.hueGreen
            : BitmapDescriptor.hueRed;

        markers.add(
          Marker(
            markerId: MarkerId(location['name']),
            position: LatLng(
              location['location']['lat'],
              location['location']['lng'],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
            infoWindow: InfoWindow(
              title: location['name'],
              snippet: location['vicinity'],
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // ให้แสดงเต็มหน้าจอถ้าจำเป็น
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                builder: (BuildContext context) {
                  return PlaceDetails(place: location);
                },
              );
            },
          ),
        );
      }
    }

    return markers.toSet();
  }

  Future<Set<Marker>> uploadMarkers_final(int dayIndex) async {
    if (uploadTrips == null || uploadTrips!.isEmpty) return {};

    List<Marker> markers = [];
    if (dayIndex == -1) {
      for (var day in uploadTrips!) {
        for (var location in day) {
          final markerColor = location['passed'] == '1'
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed;

          LatLng? snappedPosition =
              await SnapToRoadService(uploadTrips).snapToRoads(
            LatLng(
              location['location']['lat'],
              location['location']['lng'],
            ),
            googleApiKey,
          );

          if (snappedPosition != null) {
            markers.add(
              Marker(
                markerId: MarkerId(location['name']),
                position: snappedPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
                infoWindow: InfoWindow(
                  title: location['name'],
                  snippet: location['vicinity'],
                ),
                onTap: () {},
              ),
            );
          }
        }
      }
    } else if (dayIndex < uploadTrips!.length) {
      var dayLocations = uploadTrips![dayIndex];
      for (var location in dayLocations) {
        final markerColor = location['passed'] == '1'
            ? BitmapDescriptor.hueGreen
            : BitmapDescriptor.hueRed;

        LatLng? snappedPosition =
            await SnapToRoadService(uploadTrips).snapToRoads(
          LatLng(
            location['location']['lat'],
            location['location']['lng'],
          ),
          googleApiKey,
        );

        if (snappedPosition != null) {
          markers.add(
            Marker(
              markerId: MarkerId(location['name']),
              position: snappedPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
              infoWindow: InfoWindow(
                title: location['name'],
                snippet: location['vicinity'],
              ),
            ),
          );
        }
      }
    }

    return markers.toSet();
  }
}
