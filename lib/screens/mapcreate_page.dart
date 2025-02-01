import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:tripmaster/consts.dart';

class MapCreatePage extends StatefulWidget {
  const MapCreatePage({super.key});

  @override
  State<MapCreatePage> createState() => _MapCreatePageState();
}

class _MapCreatePageState extends State<MapCreatePage> {
  late GoogleMapController mapController;

  TextEditingController searchController = TextEditingController();
  LocationData? currentLocation;
  LatLng PlaceLocation = const LatLng(13.1151346, 100.9255);
  List<dynamic> suggestions = [];
  Set<Marker> markers = {};

  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
      (value) {
        setState(() {
          currentLocation = value;
          PlaceLocation = LatLng(value.latitude!, value.longitude!);
        });
        if (mapController != null) {
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(PlaceLocation, 18.0),
          );
          _fetchNearbyPlaces(PlaceLocation);
        }
      },
    );
  }

  Future<void> _fetchAutocomplete(String query) async {
    //ค้นหา
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        suggestions = data['predictions'] ?? [];
      });
    }
  }

  Future<void> _fetchNearbyPlaces(LatLng latLng) async {
    //แสดงพืนที่ใกล้เคียง
    final nearbySearchUrl = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=100&key=$googleApiKey',
    );

    final response = await http.get(nearbySearchUrl);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final places = data['results'];

      Set<Marker> newMarkers = {};

      for (var place in places) {
        final LatLng position = LatLng(
          place['geometry']['location']['lat'],
          place['geometry']['location']['lng'],
        );
        final types = place['types'] ?? [];
        final isHotel = types.contains('lodging');
        final isRestaurant = types.contains('restaurant');

        BitmapDescriptor markerColor;

        if (isHotel) {
          markerColor =
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        } else if (isRestaurant) {
          markerColor =
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        } else {
          markerColor =
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        }

        final marker = Marker(
          markerId: MarkerId(place['place_id']),
          position: position,
          icon: markerColor,
          onTap: () {
            _showPlaceDetails(place);
          },
        );

        newMarkers.add(marker);
      }

      setState(() {
        markers = newMarkers;
      });
    }
  }

  void _selectSuggestion(String placeId, String description) async {
    final placeName = description.split(',')[0];

    searchController.text = placeName;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final place = data['result'];
      final LatLng location = LatLng(
        place['geometry']['location']['lat'],
        place['geometry']['location']['lng'],
      );

      setState(() {
        PlaceLocation = location;
        suggestions = [];
      });

      mapController.animateCamera(CameraUpdate.newLatLng(location));
      _showPlaceDetails(place);
    }
  }

  void _showPlaceDetails(dynamic place) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        List<String> photoReferences = [];
        if (place['photos'] != null && place['photos'].isNotEmpty) {
          photoReferences = place['photos']
              .map<String>((photo) => photo['photo_reference'] as String)
              .toList()
              .take(1) //จำนวนรูปภาพ
              .toList();
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                place['name'] ?? 'No Name',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(place['vicinity'] ?? 'No Address'),
              const SizedBox(height: 16),
              if (photoReferences.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photoReferences.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final photoReference = photoReferences[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$googleApiKey',
                          fit: BoxFit.cover,
                          width: 150,
                          height: 100,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 15),
                    ),
                    onPressed: () {
                      final selectedPlace = {
                        'location_name': place['name'] ?? 'No Name',
                        'location_position': {
                          'lat': place['geometry']['location']['lat'],
                          'lng': place['geometry']['location']['lng'],
                        },
                        'location_vicinity': place['vicinity'] ?? 'No Address',
                      };
                      Navigator.pop(context);
                      Navigator.pop(context, selectedPlace);
                    },
                    child: const Text("Select Location",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
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
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    if (currentLocation != null) {
                      _fetchNearbyPlaces(PlaceLocation);
                      mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(PlaceLocation, 18.0),
                      );
                    }
                  },
                  onCameraIdle: () {
                    _fetchNearbyPlaces(PlaceLocation);
                  },
                  initialCameraPosition: CameraPosition(
                    target: PlaceLocation,
                    zoom: 18.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: markers,
                  onTap: (LatLng latLng) {
                    _fetchNearbyPlaces(latLng);
                    PlaceLocation = latLng;
                  },
                ),
                Positioned(
                  top: 80,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
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
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search location',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                          onChanged: _fetchAutocomplete,
                        ),
                      ),
                      if (suggestions.isNotEmpty)
                        Container(
                          color: Colors.white,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = suggestions[index];
                              return ListTile(
                                title: Text(
                                  suggestion['description'] ?? 'No Name',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                onTap: () {
                                  _selectSuggestion(suggestion['place_id'],
                                      suggestion['description'] ?? '');
                                },
                              );
                            },
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
