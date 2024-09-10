import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final mapController = MapController();
  LatLng currentLocation = LatLng(13.736717, 100.523186); // ค่าเริ่มต้น

  Future<void> _getCurrentLocation() async {
    // ขออนุญาตเข้าถึงตำแหน่งที่ตั้ง
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // แจ้งให้ผู้ใช้เปิดบริการตำแหน่งที่ตั้ง
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable location services'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // แจ้งเมื่อสิทธิ์ถูกปฏิเสธ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // แจ้งเมื่อสิทธิ์ถูกปฏิเสธอย่างถาวร
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied'),
        ),
      );
      return;
    }

    // ดึงตำแหน่งปัจจุบันของผู้ใช้
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    // ย้ายแผนที่ไปยังตำแหน่งปัจจุบัน
    mapController.move(currentLocation, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    const String mapboxAccessToken =
        'pk.eyJ1IjoiYjY0MzAzMDAwNDgiLCJhIjoiY20wbmpyOHhtMGVzODJpcTJjemp6eGlncyJ9.LP3nGO4OMeo4oIRzRB5gKg';
    const String mapboxStyleId = 'mapbox/streets-v11';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          // แผนที่ Mapbox
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: {
                  'accessToken': mapboxAccessToken,
                  'id': mapboxStyleId,
                },
                tileSize: 512,
                zoomOffset: -1,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // แถบค้นหา
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
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
          ),
          // ปุ่มฟังก์ชันด้านล่างขวา
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed:
                      _getCurrentLocation, // เมื่อกดจะระบุตำแหน่งปัจจุบัน
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    // ฟังก์ชันของปุ่มอัปโหลด
                  },
                  backgroundColor: Colors.black,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.cloud_upload,
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
