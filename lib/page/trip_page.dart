import 'package:flutter/material.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ตั้งสีพื้นหลังเป็นสีขาว
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ช่องค้นหา
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Explore previous trip',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
              children: const [
                TripList(filter: 'All'),
                TripList(filter: 'Pending'),
                TripList(filter: 'Ongoing'),
                TripList(filter: 'Completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TripList extends StatelessWidget {
  final String filter;

  const TripList({required this.filter, super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> trips = [];
    if (filter == 'All' || filter == 'Pending') {
      trips.add(const SectionHeader(title: 'Pending', color: Colors.red));
      trips.add(const TripCard(
          statusColor: Colors.red, imageAsset: 'assets/screens/homeBg.png'));
    }
    if (filter == 'All' || filter == 'Ongoing') {
      trips.add(const SectionHeader(title: 'Ongoing', color: Colors.orange));
      trips.add(const TripCard(
          statusColor: Colors.orange, imageAsset: 'assets/screens/homeBg.png'));
    }
    if (filter == 'All' || filter == 'Completed') {
      trips.add(const SectionHeader(title: 'Completed', color: Colors.green));
      trips.add(const TripCard(
          statusColor: Colors.green, imageAsset: 'assets/screens/homeBg.png'));
      trips.add(const TripCard(
          statusColor: Colors.green, imageAsset: 'assets/screens/homeBg.png'));
    }

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: trips,
    );
  }
}

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
          // เพิ่ม Padding ทางด้านซ้ายของไอคอนและข้อความ
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
  final Color statusColor;
  final String imageAsset;

  const TripCard({
    required this.statusColor,
    required this.imageAsset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // ตั้งสีพื้นหลังของ Card เป็นสีขาว
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8, // ปรับค่า elevation ให้สูงขึ้นเพื่อเพิ่มเงา
      shadowColor: Colors.black.withOpacity(0.3), // ปรับสีและความเข้มของเงา
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Trip’s name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'origin',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
                          const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'destination',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
            const SizedBox(width: 16),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_download, color: Color(0xFF000D34), size: 24),
                SizedBox(height: 8),
                Icon(Icons.send, color: Color(0xFF000D34), size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
