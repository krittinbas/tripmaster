// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmaster/service/profile_service.dart';
import 'package:tripmaster/widgets/trip_card/tripcard.dart';

class TripPage extends StatefulWidget {
  final List<Map<String, dynamic>>? newTrip;
  const TripPage({super.key, this.newTrip});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProfileService _profileService = ProfileService();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterTrips(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<String?> _fetchUserId() async {
    final userProfile = await _profileService.getUserProfile();
    if (userProfile != null) {
      return userProfile['user_id'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ตั้งสีพื้นหลังเป็นสีขาว
      body: FutureBuilder<String?>(
        future: _fetchUserId(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading user ID: ${snapshot.error}'));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user ID'));
          }

          final userId = snapshot.data;
          if (userId == null) {
            return const Center(child: Text('No user ID found'));
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Trips')
                .where('user_id', isEqualTo: userId)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              final trips = snapshot.data?.docs;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ช่องค้นหา
                        TextField(
                          controller: _searchController,
                          onChanged: _filterTrips,
                          decoration: InputDecoration(
                            hintText: 'Explore previous trip',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // TabBar สำหรับแสดงหัวข้อ All, Pending, Ongoing, Completed
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: false,
                                labelColor: const Color(0xFF000D34),
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: const Color(0xFF000D34),
                                indicatorWeight: 3,
                                tabs: const [
                                  Tab(text: 'All'),
                                  Tab(text: 'Pending'),
                                  Tab(text: 'Ongoing'),
                                  Tab(text: 'Completed'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // TabBarView สำหรับแสดงเนื้อหาตามหัวข้อที่กด
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        TripList(
                          filter: 'All',
                          trips: trips,
                          searchQuery: _searchQuery,
                        ),
                        TripList(
                          filter: 'Pending',
                          trips: trips,
                          searchQuery: _searchQuery,
                        ),
                        TripList(
                          filter: 'Ongoing',
                          trips: trips,
                          searchQuery: _searchQuery,
                        ),
                        TripList(
                          filter: 'Completed',
                          trips: trips,
                          searchQuery: _searchQuery,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class TripList extends StatelessWidget {
  final String filter;
  final List<Map<String, dynamic>>? newTrip;
  final List<QueryDocumentSnapshot>? trips;
  final String searchQuery;
  const TripList(
      {required this.filter,
      required this.trips,
      this.newTrip,
      required this.searchQuery,
      super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> tripCards = [];
    print('Trips: ${trips?.length}');
    if (trips == null || trips!.isEmpty) {
      return Center(child: Text('No trips found.'));
    }
    Set<String> displayedStatuses = {};

    final statusOrder = {
      'Pending': 0,
      'Ongoing': 1,
      'Completed': 2,
    };

    trips!.sort((a, b) {
      final Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
      final Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;

      final statusA = dataA['status'] ?? 'Pending';
      final statusB = dataB['status'] ?? 'Pending';
      return statusOrder[statusA]!.compareTo(statusOrder[statusB]!);
    });

    for (var trip in trips!) {
      try {
        final tripData = trip.data() as Map<String, dynamic>;

        final status = tripData['status'] ?? 'Pending';
        if (filter == 'All' || status == filter) {
          if (_matchesSearchQuery(tripData)) {
            if (!displayedStatuses.contains(status)) {
              tripCards.add(
                  SectionHeader(title: status, color: _getStatusColor(status)));
              displayedStatuses.add(status);
            }

            tripCards.add(TripCard(
              trip_id: tripData['trip_id'],
              statusColor: _getStatusColor(status),
              imageAsset: tripData['imageAsset'] ?? 'assets/screens/homeBg.png',
              name: tripData['trip_name'] ?? 'Trip’s name',
              origin: tripData['origin'] ?? 'origin',
              destination: tripData['destination'] ?? 'destination',
              plans: tripData['days'] ?? [],
            ));
          }
        }
      } catch (e) {
        print('Error fetching trip data: $e');
      }
    }

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: tripCards.isEmpty
          ? [Center(child: Text('No trips found for this status.'))]
          : tripCards,
    );
  }

  bool _matchesSearchQuery(Map<String, dynamic> tripData) {
    final tripName = tripData['trip_name']?.toLowerCase() ?? '';
    return tripName.contains(searchQuery.toLowerCase());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'Ongoing':
        return Colors.orange;
      case 'Completed':
        return const Color.fromARGB(255, 108, 131, 55);
      default:
        return Colors.grey;
    }
  }
}
