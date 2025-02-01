import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmaster/database/profile_service.dart';
import 'home_page.dart';
import 'package:tripmaster/screens/mapcreate_page.dart';

class TripCreatorPage extends StatefulWidget {
  const TripCreatorPage({super.key});

  @override
  State<TripCreatorPage> createState() => _TripCreatorPageState();
}

class _TripCreatorPageState extends State<TripCreatorPage> {
  final TextEditingController _tripName = TextEditingController();
  final CollectionReference _tripcollection =
      FirebaseFirestore.instance.collection('Trips');
  final ProfileService _profileService = ProfileService();

  Future<String?> _fetchUserId() async {
    final userProfile = await _profileService.getUserProfile();
    if (userProfile != null) {
      return userProfile['user_id'];
    }
    return null;
  }

  List<dynamic> plans = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trip Creator'),
      ),
      body: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 8, left: 12),
              child: Text(
                "trip's name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _tripName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length + 1,
              itemBuilder: (context, index) {
                if (index == plans.length) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          plans.add([]);
                          print("days ${plans}");
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 35),
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add Day'),
                    ),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Day - ${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (plans[index]
                          .isEmpty) // Validation: Check if the day has valid data
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'This day has no places added',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      Column(
                        children: plans[index].map<Widget>((place) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, top: 8, bottom: 8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/screens/dot.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place['location_name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(place['location_vicinity'] ??
                                          'No Address'),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  color: Colors.white,
                                  onSelected: (value) async {
                                    if (value == 'Edit') {
                                      final updatedPlace = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MapCreatePage(),
                                        ),
                                      );
                                      if (updatedPlace != null) {
                                        setState(() {
                                          int placeIndex =
                                              plans[index].indexOf(place);
                                          plans[index][placeIndex] =
                                              updatedPlace;
                                          print("Edited Days: $plans");
                                        });
                                      }
                                    } else if (value == 'Delete') {
                                      setState(() {
                                        plans[index].remove(place);
                                      });
                                      print("Deleteed Days: $plans");
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<String>(
                                      value: 'Edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'Delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            final selectedPlaces = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MapCreatePage(),
                              ),
                            );

                            if (selectedPlaces != null) {
                              setState(() {
                                plans[index].add(selectedPlaces);
                                print("Updated Days: $plans");
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 25),
                            textStyle: const TextStyle(fontSize: 25),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('+'),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("cancel",
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
                  onPressed: plans.any((day) => day.isEmpty)
                      ? null
                      : () async {
                          String? userId = await _fetchUserId();

                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Unable to fetch user ID')),
                            );
                            return;
                          }

                          for (var day in plans) {
                            for (var location in day) {
                              location['passed'] = '0';
                              var querySnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('Location')
                                  .where('location_name',
                                      isEqualTo: location['location_name'])
                                  .where('location_vicinity',
                                      isEqualTo: location['location_vicinity'])
                                  .limit(1)
                                  .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                location['location_id'] =
                                    querySnapshot.docs.first.id;
                              } else {
                                var newLocation = await FirebaseFirestore
                                    .instance
                                    .collection('Location')
                                    .add({
                                  'location_name': location['location_name'],
                                  'location_vicinity':
                                      location['location_vicinity'],
                                  'location_position':
                                      location['location_position'],
                                });

                                await newLocation.update({
                                  'location_id': newLocation.id,
                                });
                                location['location_id'] = newLocation.id;
                              }
                            }
                          }
                          plans.first[0]['passed'] = '1';

                          if (_tripName.text.isNotEmpty && plans.isNotEmpty) {
                            List<Map<String, dynamic>> TripTest =
                                plans.map((day) {
                              return {
                                'places': day,
                              };
                            }).toList();

                            try {
                              var trip2 = await _tripcollection.add({
                                'trip_name': _tripName.text,
                                'origin':
                                    plans.isNotEmpty && plans.first.isNotEmpty
                                        ? plans.first.first['location_name'] ??
                                            'No Origin'
                                        : 'No Origin',
                                'destination':
                                    plans.isNotEmpty && plans.last.isNotEmpty
                                        ? plans.last.last['location_name'] ??
                                            'No Destination'
                                        : 'No Destination',
                                'plan': TripTest,
                                'timestamp': FieldValue.serverTimestamp(),
                                'status': 'Pending',
                                'user_id': userId,
                              });
                              await trip2.update({
                                'trip_id': trip2.id,
                              });
                              print("check plantrip: $trip2");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(
                                    initialIndex: 1,
                                  ),
                                ),
                              );
                            } catch (e) {
                              print("Error adding trip: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Error saving trip')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill in all fields')),
                            );
                          }
                        },
                  child: const Text("save trip",
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }
}
