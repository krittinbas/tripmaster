import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripmaster/services/marker.dart';
import 'package:tripmaster/services/polyline_service.dart';

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
  final PolylineService polylineService = PolylineService();

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
    });
    _updateMarkers();
    _updatePolylines();
  }

  Future<void> _updatePolylines() async {
    Set<Polyline> polylines =
        await polylineService.updatePolylines(upload_trips, selectedDay);

    setState(() {
      _polylines = polylines;
    });
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
    _updateMarkers();
    _updatePolylines();
  }

  void _updateMarkers() async {
    Set<Marker> markers = await uploadMarkers(
        selectedDay, upload_trips, context, updatePassStatus);

    setState(() {
      mapMarkers = markers;
    });
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
                                    _updateMarkers();
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
                        onPressed: () async {
                          if (await _controller.isCompleted) {
                            mapController = await _controller.future;
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(currentLocation!.latitude!,
                                    currentLocation!.longitude!),
                              ),
                            );
                          }
                        },
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
                            _updateMarkers();
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
