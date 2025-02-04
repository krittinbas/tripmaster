import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:tripmaster/page/map/map_action_buttons.dart';
import 'package:tripmaster/page/map/map_bottom_sheet.dart';
import 'package:tripmaster/page/map/map_search_bar.dart';
import 'package:http/http.dart' as http;
import '../../constants/constants.dart';

class MapPage extends StatefulWidget {
  final Map<String, dynamic>? initialPlace; // เพิ่มพารามิเตอร์ใหม่

  const MapPage({super.key, this.initialPlace}); // แก้ไขคอนสตรักเตอร์

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
    }
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
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(
              bottom: isBottomSheetVisible ? _bottomSheetHeight - 40 : 0,
            ),
          ),
          MapSearchBar(
            searchController: searchController,
            onSelect: _selectPlace,
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
