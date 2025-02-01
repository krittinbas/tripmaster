import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripmaster/constants/constants.dart';

import 'package:tripmaster/widgets/placedetails.dart';

class MapPage extends StatefulWidget {
  final String? trip_id;

  const MapPage({super.key, this.trip_id});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late GoogleMapController mapController;

  LocationData? currentLocation;

  Set<Marker> mapMarkers = {};
  Set<Polyline> _polylines = {};

  int selectedDay = -1;
  Map<String, dynamic> upload_trips = {};
  final PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();

    fetchTripData();
    _updatePolylines();
  }

  Future<void> fetchTripData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Trips')
        .doc(widget.trip_id)
        .get();

    setState(() {
      upload_trips = snapshot.data() as Map<String, dynamic>;
      if (upload_trips != null) {
        mapMarkers = uploadMarkers(selectedDay, context);
      }
    });
    _updatePolylines();
  }

  Future<void> _updatePolylines() async {
    _polylines.clear(); // ล้าง polyline เก่าออก
    List<LatLng> polylineCoordinates = [];

    if (upload_trips.isEmpty || !upload_trips.containsKey('plan')) return;

    List<dynamic> days = upload_trips['plan'];
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

        List<LatLng> route = await _getPolylinePoints(start, end);

        List<LatLng> routeCoordinates = List.from(route);
        polylineCoordinates = routeCoordinates;

        String polylineId = "day_${dayIndex}_segment_${i}_to_${i + 1}";

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId(polylineId),
              color: isPassed
                  ? const Color.fromARGB(255, 108, 131, 55)
                  : Colors.grey,
              width: 5,
              points: polylineCoordinates,
            ),
          );
        });
      }
    }
  }

  Future<List<LatLng>> _getPolylinePoints(LatLng start, LatLng end) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
          origin: PointLatLng(start.latitude, start.longitude),
          destination: PointLatLng(end.latitude, end.longitude),
          mode: TravelMode.driving),
    );

    if (result.points.isNotEmpty) {
      return result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } else {
      print("Failed to get polyline: ${result.errorMessage}");
      return [];
    }
  }

  void updatePassStatus() async {
    List<List<int>> passStatus = upload_trips['plan']
        .map<List<int>>((day) => List<int>.from(
            day['places'].map<int>((place) => place['passed'] == '1' ? 1 : 0)))
        .toList();

    print('passStatus before: $passStatus');

    for (int i = 0; i < passStatus.length; i++) {
      if (passStatus[i].last == 1 && i + 1 < passStatus.length) {
        passStatus[i + 1][0] = 1;
      }
    }
    bool foundOne = false;
    for (int i = passStatus.length - 1; i >= 0; i--) {
      for (int j = passStatus[i].length - 1; j >= 0; j--) {
        if (passStatus[i][j] == 1) {
          foundOne = true;
        }

        if (foundOne) {
          passStatus[i][j] = 1;
        }
      }
    }

    print('passStatus after: $passStatus');
    for (int dayIndex = 0; dayIndex < upload_trips['plan'].length; dayIndex++) {
      for (int placeIndex = 0;
          placeIndex < upload_trips['plan'][dayIndex]['places'].length;
          placeIndex++) {
        upload_trips['plan'][dayIndex]['places'][placeIndex]['passed'] =
            passStatus[dayIndex][placeIndex] == 1 ? '1' : '0';
      }
    }

    bool checkStatus = true;
    for (var day in passStatus) {
      if (day.contains(0)) {
        checkStatus = false;
        break;
      }
    }

    if (checkStatus) {
      upload_trips['status'] = 'Completed';
    }

    String tripId = upload_trips['trip_id'];
    try {
      await FirebaseFirestore.instance.collection('Trips').doc(tripId).update({
        'plan': upload_trips['plan'],
        'status': upload_trips['status'],
      });

      print('save succeed');
    } catch (e) {
      print('error: $e');
    }
    mapMarkers = uploadMarkers(selectedDay, context);
    _updatePolylines();
  }

  Future<LatLng> snapToRoad(LatLng location) async {
    final url =
        'https://roads.googleapis.com/v1/snapToRoads?path=${location.latitude},${location.longitude}&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['snappedPoints'] != null && data['snappedPoints'].isNotEmpty) {
        final snappedLat = data['snappedPoints'][0]['location']['latitude'];
        final snappedLng = data['snappedPoints'][0]['location']['longitude'];
        return LatLng(snappedLat, snappedLng);
      } else {
        return location; // Return original if no snapped point is found
      }
    } else {
      throw Exception('Failed to snap to road');
    }
  }

  Set<Marker> uploadMarkers(int dayIndex, BuildContext context) {
    if (upload_trips.isEmpty) return {};

    List<Marker> markers = [];
    if (dayIndex == -1) {
      // รวม Marker จากทุกวัน
      for (var places in upload_trips['plan']!) {
        print('checktestday: $places');
        for (var location in places['places']) {
          print('checktestlocation: $location');
          final markerColor = location['passed'] == '1'
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed;

          print('MarkerId: ${location['location_name']}');
          markers.add(
            Marker(
              markerId: MarkerId(location['location_name']),
              position: LatLng(
                location['location_position']['lat'],
                location['location_position']['lng'],
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
              onTap: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return PlaceDetails(place: location);
                  },
                );

                if (result == 'checked_in') {
                  setState(() {
                    print("hellotrip : $upload_trips");
                    updatePassStatus();
                  });
                }
              },
            ),
          );
        }
      }
    } else if (dayIndex < upload_trips['plan'].length) {
      print("upload_trips['plan'] ${upload_trips['plan']}");
      var dayLocations = upload_trips['plan'][dayIndex];
      for (var location in dayLocations['places']) {
        final markerColor = location['passed'] == '1'
            ? BitmapDescriptor.hueGreen
            : BitmapDescriptor.hueRed;

        markers.add(
          Marker(
            markerId: MarkerId(location['location_name']),
            position: LatLng(
              location['location_position']['lat'],
              location['location_position']['lng'],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
            onTap: () async {
              final result = await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return PlaceDetails(place: location);
                },
              );

              if (result == 'checked_in') {
                setState(() {
                  updatePassStatus();
                });
              }
            },
          ),
        );
      }
    }

    return markers.toSet();
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
      (value) {
        setState(() {
          currentLocation = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(child: Text("Loading"))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) =>
                      _controller.complete(controller),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 18.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: mapMarkers.toSet(),
                  polylines: _polylines,
                ),
                Positioned(
                  top: 80,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      // Search TextField
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search location',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(
                            upload_trips['plan']?.length ?? 0,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, right: 4),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (selectedDay == index) {
                                      selectedDay = -1;
                                    } else {
                                      selectedDay = index;
                                    }
                                    mapMarkers =
                                        uploadMarkers(selectedDay, context);
                                    _updatePolylines();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedDay == index
                                      ? Colors.black
                                      : Colors.white,
                                  foregroundColor: selectedDay == index
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                child: Text('Day ${index + 1}'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        onPressed: () {},
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () {},
                        backgroundColor: Colors.black,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.cloud_upload,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            mapMarkers = uploadMarkers(selectedDay, context);
                            _updatePolylines();
                          });
                        },
                        backgroundColor: Colors.black,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
