import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // ตัวควบคุม TabBar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // กำหนดจำนวน Tab
  }

  @override
  void dispose() {
    _tabController.dispose(); // ทำการ dispose _tabController เมื่อไม่ใช้งาน
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ตั้งสีพื้นหลังของ Scaffold เป็นสีขาว
      appBar: AppBar(
        backgroundColor: Colors.white, // ตั้งสีพื้นหลัง AppBar เป็นสีขาว
        elevation: 0,
        title: const Text(
          '@username',
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
          // ส่วนโปรไฟล์และปุ่มแก้ไข
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ProfileStat(label: 'follower', count: 142),
                              SizedBox(width: 30),
                              _ProfileStat(label: 'following', count: 23),
                              SizedBox(width: 30),
                              _ProfileStat(label: 'trips taken', count: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000D34),
                          ),
                        ),
                        Text(
                          'Bio profile or description',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white, // ตั้งสีพื้นหลังปุ่มเป็นสีขาว
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: const BorderSide(color: Color(0xFF000D34)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 0), // ปรับระยะห่างของตัวอักษรกับขอบ
                        ),
                        child: const Text(
                          'edit profile',
                          style: TextStyle(
                            fontSize: 14, // ปรับขนาดตัวอักษรของปุ่ม
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000D34),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF000D34)),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          size: 25, // ปรับขนาดไอคอนส่ง
                          color: Color(0xFF000D34),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // TabBar สำหรับแสดงไอคอนและการเลือก
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF000D34),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF000D34),
            tabs: const [
              Tab(
                  icon: Icon(Icons.grid_view,
                      size: 28)), // ปรับขนาดไอคอนแท็บที่ 1
              Tab(
                  icon: Icon(Icons.bookmark_border,
                      size: 28)), // ปรับขนาดไอคอนแท็บที่ 2
              Tab(icon: Icon(Icons.group, size: 28)), // ปรับขนาดไอคอนแท็บที่ 3
            ],
          ),
          // TabBarView สำหรับเนื้อหาในแต่ละแท็บ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Grid View Content'),
                _buildTabContent('Bookmarks Content'),
                _buildTabContent('Groups Content'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้างเนื้อหาสำหรับแต่ละแท็บ
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
