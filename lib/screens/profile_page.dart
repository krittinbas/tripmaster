import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000D34)),
          onPressed: () {},
        ),
        title: const Text(
          '@Username',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000D34),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF000D34),
              size: 25,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Profile Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000D34),
                  ),
                ),
                const Text(
                  '@Username',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Lorem ipsum dolor sit amet consectetur. Turpis vitae semper dui bibendum',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStat(label: 'Followers', count: 2152),
                    _ProfileStat(label: 'Following', count: 325),
                    _ProfileStat(label: 'Trips taken', count: 11),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOutlinedButton(Icons.person, 'Follow', 150, 36),
                    const SizedBox(width: 10),
                    _buildOutlinedButton(Icons.send, 'Share', 150, 36),
                    const SizedBox(width: 10),
                    _buildIconButton(Icons.notifications, 40, 36),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF000D34),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF000D34),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'My post'),
              Tab(text: 'Mentioned'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('My Post Content'),
                _buildTabContent('Mentioned Content'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(
      IconData icon, String label, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF000D34)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        icon: Icon(
          icon,
          color: const Color(0xFF000D34),
          size: 20,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF000D34),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF000D34)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF000D34),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTabContent(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final int count;

  const _ProfileStat({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000D34),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
