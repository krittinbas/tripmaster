import 'package:flutter/material.dart';

class DayDetailsWidget extends StatelessWidget {
  final List<dynamic> plans;

  const DayDetailsWidget({required this.plans, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  padding: EdgeInsets.symmetric(vertical: 8.0),
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            place['passed'] == '1'
                                ? const Color.fromARGB(255, 108, 131, 55)
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
                              place['location_vicinity'] ?? 'No Address',
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
    );
  }
}
