import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmaster/page/editdetail_page.dart';
import 'package:tripmaster/page/home_page.dart';
import 'package:tripmaster/widgets/details/edit_button.dart';
import 'package:tripmaster/widgets/details/image_details.dart';
import 'package:tripmaster/widgets/trip_card/tripcard.dart';

import '../widgets/details/day_detail.dart';

class TripDetailsPage extends StatelessWidget {
  final String trip_id;
  final Color statusColor;
  final String name;
  final List<String> imageAsset;
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
                        ImageSliderWidget(imageAsset: imageAsset),
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
                        DayDetailsWidget(plans: plans),
                      ],
                    ),
                  ),
                ),
                EditButtonWidget(
                  trip_id: trip_id,
                  statusColor: statusColor,
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
