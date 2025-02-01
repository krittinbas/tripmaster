import 'package:flutter/material.dart';
import 'package:tripmaster/screens/detailcard_page.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const SectionHeader({required this.title, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // ระยะห่างแนวตั้ง
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // เพิ่มระยะห่างด้านซ้าย
            child: Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000D34),
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

class TripCard extends StatelessWidget {
  final String trip_id;
  final Color statusColor;
  final String imageAsset;
  final String name;
  final String origin;
  final String destination;
  final List<dynamic> plans;

  TripCard({
    required this.trip_id,
    required this.statusColor,
    required this.imageAsset,
    required this.name,
    required this.origin,
    required this.destination,
    required this.plans,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsPage(
              trip_id: trip_id,
              plans: [plans],
              imageAsset: imageAsset,
              name: name,
              origin: origin,
              destination: destination,
              statusColor: statusColor,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imageAsset,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        name.isNotEmpty ? name : 'Trip’s name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle,
                                    size: 8, color: Colors.grey),
                                const SizedBox(width: 4),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 200),
                                  child: Text(
                                    origin.isNotEmpty ? origin : 'origin',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1.5,
                              height: 16,
                              color: Colors.grey[400],
                              margin: const EdgeInsets.only(left: 4),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.circle,
                                    size: 8, color: Colors.grey),
                                const SizedBox(width: 4),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 200),
                                  child: Text(
                                    destination.isNotEmpty
                                        ? destination
                                        : 'destination',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_download,
                        color: Color(0xFF000D34), size: 24),
                    SizedBox(height: 8),
                    Icon(Icons.send, color: Color(0xFF000D34), size: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TripInfoBox extends StatelessWidget {
  final Color statusColor;
  final String origin;
  final String destination;
  final String origin_vicinity;
  final String destination_vicinity;
  final List<dynamic> plans;

  const TripInfoBox({
    required this.statusColor,
    required this.origin,
    required this.destination,
    required this.origin_vicinity,
    required this.destination_vicinity,
    required this.plans,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int totalDays = plans.length;

    final int totalLocations = 2;

    String filter = "";
    if (statusColor == Colors.red) {
      filter = "pending";
    } else if (statusColor == Colors.orange) {
      filter = "Ongoing";
    } else if (statusColor == Colors.green) {
      filter = "Completed";
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Colors.grey,
            width: 0.5,
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/screens/dot.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              origin.isNotEmpty ? origin : 'origin',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              origin_vicinity,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/screens/dot.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.isNotEmpty
                                  ? destination
                                  : 'destination',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              destination_vicinity,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  filter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Trip span: $totalDays days | $totalLocations locations',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
