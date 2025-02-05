import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmaster/screens/home_page.dart';
import 'package:tripmaster/screens/mapcreate_page.dart';
import 'package:tripmaster/widgets/TripCard.dart';

class EditdetailPage extends StatefulWidget {
  final String trip_id;
  final Color statusColor;

  const EditdetailPage({
    required this.trip_id,
    required this.statusColor,
    super.key,
  });

  @override
  State<EditdetailPage> createState() => _EditdetailPageState();
}

class _EditdetailPageState extends State<EditdetailPage> {
  final TextEditingController _tripName = TextEditingController();
  Map<String, dynamic>? tripData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTripData(); // โหลดข้อมูลเมื่อเริ่มหน้า
  }

  Future<void> _loadTripData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Trips')
          .doc(widget.trip_id)
          .get();

      if (doc.exists) {
        setState(() {
          tripData = doc.data() as Map<String, dynamic>;

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading trip data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveTripData() async {
    if (tripData == null ||
        tripData!['plan'] == null ||
        tripData!['plan'].isEmpty) {
      return print('Trip data or plan is null or empty');
    }

    for (var day in tripData!['plan']) {
      bool FirstLocation = true;
      for (var location in day['places']) {
        if (FirstLocation) {
          location['passed'] = '1';
          FirstLocation = false;
        } else {
          location['passed'] = '0';
        }

        String locationName = location['location_name'] ?? 'Unknown Name';
        String locationVicinity = location['location_vicinity'] ?? 'No Address';
        var locationPosition = location['location_position'] ?? {};

        var querySnapshot = await FirebaseFirestore.instance
            .collection('Location')
            .where('location_name', isEqualTo: locationName)
            .where('location_vicinity', isEqualTo: locationVicinity)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          location['location_id'] = querySnapshot.docs.first.id;
        } else {
          var newLocation =
              await FirebaseFirestore.instance.collection('Location').add({
            'location_name': locationName,
            'location_vicinity': locationVicinity,
            'location_position': locationPosition,
          });

          await newLocation.update({
            'location_id': newLocation.id,
          });
          location['location_id'] = newLocation.id;
        }
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('Trips')
          .doc(widget.trip_id)
          .update({
        'trip_name':
            _tripName.text.isNotEmpty ? _tripName.text : tripData!['trip_name'],
        'plan': tripData!['plan'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip updated successfully')),
      );
    } catch (e) {
      print('Error saving trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save trip')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tripData == null) {
      return const Scaffold(
        body: Center(child: Text("No trip data available")),
      );
    }
    final String name = tripData!['trip_name'] ?? 'Trip Details';
    final List<dynamic> plans = tripData!['plan'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editor'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Trip's name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _tripName,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    hintText: name,
                    hintStyle: const TextStyle(color: Colors.grey)),
                style: const TextStyle(fontSize: 18),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8, top: 16, bottom: 16),
                  child: TripInfoBox(
                    statusColor: widget.statusColor,
                    origin: plans[0]['places'][0]['location_name'],
                    destination: plans.last['places'].last['location_name'],
                    plans: plans,
                    origin_vicinity:
                        (plans.isNotEmpty && plans.first.isNotEmpty)
                            ? (plans[0]['places'][0]['location_vicinity'] ??
                                'No Address')
                            : 'No Address',
                    destination_vicinity:
                        (plans.isNotEmpty && plans.last.isNotEmpty)
                            ? (plans.last['places'].last['location_vicinity'] ??
                                'No Address')
                            : 'No Address',
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(plans.length, (index) {
                    final day = plans[index];
                    print('Day content: $day');

                    List<Widget> placeWidgets = [];

                    day['places'].forEach((place) {
                      placeWidgets.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place['location_name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      place['location_vicinity'] ??
                                          'No Address',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: PopupMenuButton<String>(
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
                                          int placeIndex = plans[index]
                                                  ['places']
                                              .indexOf(place);
                                          plans[index]['places'][placeIndex]
                                                  ['location_name'] =
                                              updatedPlace['location_name'];
                                          plans[index]['places'][placeIndex]
                                                  ['location_vicinity'] =
                                              updatedPlace['location_vicinity'];
                                          plans[index]['places'][placeIndex]
                                                  ['location_position'] =
                                              updatedPlace['location_position'];
                                        });
                                        print("updatedPlace Days: $plans");
                                      }
                                    } else if (value == 'Delete') {
                                      setState(() {
                                        plans[index]['places'].remove(place);
                                      });
                                      print("Deleted Days: $plans");
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
                              ),
                            ],
                          ),
                        ),
                      );
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day - ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...placeWidgets,
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
                                  plans[index]['places'].add({
                                    'location_name':
                                        selectedPlaces['location_name'],
                                    'location_vicinity':
                                        selectedPlaces['location_vicinity'],
                                    'location_position':
                                        selectedPlaces['location_position'],
                                    'passed': '0',
                                  });
                                });
                                print("Add Days: $plans");
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
                        const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                          height: 32.0,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text("cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                ),
                onPressed: () async {
                  tripData!['plan'] = plans;
                  print('check last plan 1: ${tripData!['plan']}');
                  print(
                      'check last plan 2: ${tripData!['plan'][0]['places'][0]['passed'][0]}');
                  await _saveTripData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        initialIndex: 1,
                      ),
                    ),
                  );
                },
                child:
                    const Text('save', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
