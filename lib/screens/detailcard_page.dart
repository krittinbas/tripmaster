import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmaster/screens/editdetail_page.dart';
import 'package:tripmaster/screens/home_page.dart';
import 'package:tripmaster/widgets/TripCard.dart';

class TripDetailsPage extends StatelessWidget {
  final String trip_id;
  final Color statusColor;
  final String name;
  final String imageAsset;
  final String origin;
  final String destination;
  final List<List<dynamic>> plans;

  const TripDetailsPage({
    required this.trip_id,
    required this.statusColor,
    required this.name,
    required this.imageAsset,
    required this.origin,
    required this.destination,
    required this.plans,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('Trips').doc(trip_id).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Loading..."));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No trip data available"));
            }

            final tripData = snapshot.data!.data() as Map<String, dynamic>;
            final String name = tripData['trip_name'] ?? 'Trip Details';
            final String imageAsset =
                tripData['imageAsset'] ?? 'assets/screens/homeBg.png';
            final String origin = tripData['origin'] ?? 'Unknown Origin';
            final String destination =
                tripData['destination'] ?? 'Unknown Destination';
            final List<dynamic> plans = tripData['plan'] ?? [];
            print('check days : $plans');

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          name.isNotEmpty ? name : "Trip Details",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              imageAsset,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8, top: 16, bottom: 16),
                            child: TripInfoBox(
                              statusColor: statusColor,
                              origin: origin,
                              destination: destination,
                              plans: plans,
                              origin_vicinity:
                                  (plans.isNotEmpty && plans.first.isNotEmpty)
                                      ? (plans[0]['places'][0]
                                              ['location_vicinity'] ??
                                          'No Address')
                                      : 'No Address',
                              destination_vicinity:
                                  (plans.isNotEmpty && plans.last.isNotEmpty)
                                      ? (plans.last['places']
                                              .last['location_vicinity'] ??
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
                              if (day['places'].isEmpty) {
                                placeWidgets.add(
                                  const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        "No places added yet",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                day['places'].forEach((place) {
                                  placeWidgets.add(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                place['passed'] == '1'
                                                    ? const Color.fromARGB(
                                                        255, 108, 131, 55)
                                                    : Colors.black,
                                                BlendMode.srcATop,
                                              ),
                                              child: Image.asset(
                                                'assets/screens/dot.png',
                                                width: 30,
                                                height: 30,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  place['location_name'] ??
                                                      'No Name',
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
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              }
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
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                    height: 32.0,
                                  ),
                                ],
                              );
                            }),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 32),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            showMenu(
                              color: Colors.white,
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              position:
                                  const RelativeRect.fromLTRB(0, 625, 0, 0),
                              items: [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    title: Text('Edit'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                              elevation: 8.0,
                            ).then((value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditdetailPage(
                                      trip_id: trip_id,
                                      statusColor: statusColor,
                                    ),
                                  ),
                                );
                              } else if (value == 'delete') {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: const EdgeInsets.all(16.0),
                                      height: 150,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16.0),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Are you sure you want to delete this trip?',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Text(
                                            'This action cannot be undone.',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    side: const BorderSide(
                                                        color: Colors.black,
                                                        width: 2),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 60,
                                                      vertical: 15),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("cancel",
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ),
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 60,
                                                        vertical: 15),
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('Trips')
                                                          .doc(trip_id)
                                                          .delete();
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    } catch (e) {
                                                      print(
                                                          'Error deleting trip: $e');
                                                    }
                                                  },
                                                  child: const Text('delete',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            });
                          },
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          onPressed: () {},
                          backgroundColor: Colors.black,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.map_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
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
                  try {
                    if (statusColor != Colors.green) {
                      await FirebaseFirestore.instance
                          .collection('Trips')
                          .doc(trip_id)
                          .update({
                        'status': 'Ongoing',
                      });
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          trip_id: trip_id,
                          initialIndex: 2,
                        ),
                      ),
                    );
                  } catch (e) {
                    print('Error updating trip: $e');
                  }
                },
                child: const Text('upload map',
                    style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
