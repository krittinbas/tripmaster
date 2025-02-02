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
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng? currentLocation; // เปลี่ยนเป็น nullable
  Set<Marker> markers = {};
  final searchController = TextEditingController();
  String? selectedPlaceName;
  String? selectedPlaceAddress;
  List<String> placeImages = [];
  bool isBottomSheetVisible = false;
  final double _bottomSheetHeight = 220.0;

  // ตำแหน่งเริ่มต้นของแผนที่ (กรุงเทพฯ)
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
    _getCurrentLocation();
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

  Future<void> _selectPlace(Prediction prediction) async {
    if (prediction.placeId == null) return;

    try {
      final apiKey = googleApiKey;
      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] != 'OK') return;

      final result = data['result'];
      final lat = result['geometry']['location']['lat'] as double;
      final lng = result['geometry']['location']['lng'] as double;

      final placeLocation = LatLng(lat, lng);

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
          placeImages = [
            'https://source.unsplash.com/400x300/?place,building',
            'https://source.unsplash.com/400x300/?architecture',
            'https://source.unsplash.com/400x300/?interior',
            'https://source.unsplash.com/400x300/?restaurant',
          ];
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
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: currentLocation ??
                  defaultLocation, // ใช้ตำแหน่งเริ่มต้นถ้ายังไม่มีตำแหน่งจริง
              zoom: 15,
            ),
            markers: markers, // markers จะว่างเปล่าจนกว่าจะได้ตำแหน่งจริง
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
