import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:tripmaster/page/map/map_action_buttons.dart';
import 'package:tripmaster/page/map/map_bottom_sheet.dart';
import 'package:tripmaster/page/map/map_search_bar.dart';
import 'package:http/http.dart' as http;
import 'package:tripmaster/service/marker.dart';
import 'package:tripmaster/service/polyline_service.dart';
import '../../constants/constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  final Map<String, dynamic>? initialPlace; // เพิ่มพารามิเตอร์ใหม่
  final String? trip_id;

  const MapPage(
      {super.key, this.initialPlace, this.trip_id}); // แก้ไขคอนสตรักเตอร์

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Set<Marker> markers = {};
  final searchController = TextEditingController();
  String? selectedPlaceName;
  String? selectedPlaceAddress;
  List<String> placeImages = [];
  bool isBottomSheetVisible = false;
  final double _bottomSheetHeight = 220.0;

  final LatLng defaultLocation = const LatLng(13.736717, 100.523186);

  Set<Marker> mapMarkers = {};
  Set<Polyline> _polylines = {};

  int selectedDay = -1;
  Map<String, dynamic> upload_trips = {};
  final PolylinePoints polylinePoints = PolylinePoints();
  final PolylineService polylineService = PolylineService();

  @override
  void dispose() {
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialPlace != null) {
      // เพิ่มเงื่อนไขตรวจสอบ initialPlace
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInitialPlace();
      });
    } else {
      _getCurrentLocation();
      fetchTripData();
      _updatePolylines();
    }
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          currentLocation = newLocation;
          markers = {
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: newLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          };
        });

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLocation,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  // แก้ไขเมธอด _showInitialPlace()
  void _showInitialPlace() async {
    if (widget.initialPlace == null) return;

    final location = widget.initialPlace!['location'] as LatLng;
    final name = widget.initialPlace!['name'] as String;
    final address = widget.initialPlace!['address'] as String;
    final placeId = widget.initialPlace!['placeId'] as String;

    // ดึงข้อมูลรูปภาพจาก Place Details API
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=photos&key=$googleApiKey',
      );

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      List<String> photoUrls = [];
      if (data['result']?['photos'] != null) {
        for (var photo in data['result']['photos']) {
          final photoReference = photo['photo_reference'];
          final photoUrl =
              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$googleApiKey';
          photoUrls.add(photoUrl);
        }
      }

      setState(() {
        markers = {
          Marker(
            markerId: MarkerId(placeId),
            position: location,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: name,
              snippet: address,
            ),
          ),
        };

        selectedPlaceName = name;
        selectedPlaceAddress = address;
        placeImages = photoUrls.isNotEmpty
            ? photoUrls
            : [
                'https://source.unsplash.com/400x300/?place,building',
              ]; // Fallback image ถ้าไม่มีรูป
        isBottomSheetVisible = true;
      });

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching place photos: $e');
      // ใช้รูปภาพ fallback ถ้าเกิดข้อผิดพลาด
      setState(() {
        placeImages = ['https://source.unsplash.com/400x300/?place,building'];
      });
    }
  }

// แก้ไขเมธอด _selectPlace() เพื่อดึงรูปภาพเช่นกัน
  Future<void> _selectPlace(Prediction prediction) async {
    if (prediction.placeId == null) return;

    try {
      final apiKey = googleApiKey;
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&fields=geometry,photos&key=$apiKey',
      );

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['status'] != 'OK') return;

      final result = data['result'];
      final lat = result['geometry']['location']['lat'] as double;
      final lng = result['geometry']['location']['lng'] as double;
      final placeLocation = LatLng(lat, lng);

      // ดึงรูปภาพ
      List<String> photoUrls = [];
      if (result['photos'] != null) {
        for (var photo in result['photos']) {
          final photoReference = photo['photo_reference'];
          final photoUrl =
              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
          photoUrls.add(photoUrl);
        }
      }

      if (mounted) {
        setState(() {
          markers = {
            Marker(
              markerId: MarkerId(prediction.placeId!),
              position: placeLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: prediction.structuredFormatting?.mainText,
                snippet: prediction.structuredFormatting?.secondaryText,
              ),
            ),
          };

          selectedPlaceName = prediction.structuredFormatting?.mainText;
          selectedPlaceAddress = prediction.structuredFormatting?.secondaryText;
          placeImages = photoUrls.isNotEmpty
              ? photoUrls
              : ['https://source.unsplash.com/400x300/?place,building'];
          isBottomSheetVisible = true;
        });

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: placeLocation,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching place details: $e')),
        );
      }
      print('Error fetching place details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดตำแหน่งเริ่มต้นจาก initialPlace ถ้ามี
    final initialPosition = widget.initialPlace != null
        ? widget.initialPlace!['location'] as LatLng
        : (currentLocation ?? defaultLocation);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              // ถ้ามี initialPlace ให้แสดงทันทีที่แผนที่พร้อม
              if (widget.initialPlace != null) {
                _showInitialPlace();
              }
            },
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 15,
            ),
            markers: mapMarkers.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(
              bottom: isBottomSheetVisible ? _bottomSheetHeight - 40 : 0,
            ),
            polylines: _polylines,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MapSearchBar(
                searchController: searchController,
                onSelect: _selectPlace,
              ),
              Row(
                children: [
                  ...List.generate(
                    upload_trips['plan']?.length ?? 0,
                    (index) => Padding(
                      padding: const EdgeInsets.only(top: 4.0, right: 4),
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
          MapBottomSheet(
            isVisible: isBottomSheetVisible,
            selectedPlaceName: selectedPlaceName,
            selectedPlaceAddress: selectedPlaceAddress,
            placeImages: placeImages,
            bottomSheetHeight: _bottomSheetHeight,
            onVisibilityChanged: (visible) {
              setState(() {
                isBottomSheetVisible = visible;
              });
            },
          ),
          MapActionButtons(
            isBottomSheetVisible: isBottomSheetVisible,
            bottomSheetHeight: _bottomSheetHeight,
            onLocationPressed: _getCurrentLocation,
          ),
        ],
      ),
    );
  }
}
