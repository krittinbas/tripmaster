import 'package:flutter/material.dart';
import 'package:tripmaster/routes/bottom_navigation.dart'; // Import ไฟล์ BottomNavigationBar ที่แยกออกมา
import 'board_page.dart'; // Import หน้า Board
import 'map_page.dart'; // Import หน้า Map
import 'profile_page.dart'; // Import หน้า Profile
import 'trip_page.dart'; // Import หน้า Trip

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // ตัวแปรสำหรับเก็บ index ที่ถูกเลือก

  // ฟังก์ชันเมื่อมีการกดที่ BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex =
          index; // เปลี่ยน index เมื่อมีการกดที่ BottomNavigationBar
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index:
            _selectedIndex, // ใช้ index จาก _selectedIndex เพื่อควบคุมการแสดงผล
        children: const [
          HomeScreen(), // หน้า Home
          TripPage(), // หน้า Trip
          MapPage(), // หน้า Map
          BoardPage(), // หน้า Board
          ProfilePage(), // หน้า Profile
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/screens/homeBg.png'),
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        // Content Area
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 540, // กำหนดความสูงของเนื้อหา
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text.rich(
                  TextSpan(
                    text: 'Planning Your Next ', // ข้อความส่วนแรก
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // สีของข้อความส่วนแรก
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            '\nTrip Destination', // ข้อความที่ต้องการเปลี่ยนสี
                        style: TextStyle(
                          color: Color(
                              0xFF6B852F), // สีเฉพาะของคำว่า Trip Destination
                          fontWeight:
                              FontWeight.bold, // สามารถกำหนดสไตล์เพิ่มเติมได้
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 210),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000D34),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 90, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Create Trip',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 90, vertical: 15),
                    side: const BorderSide(color: Color(0xFF000D34)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Join Tour',
                    style: TextStyle(color: Color(0xFF000D34), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
