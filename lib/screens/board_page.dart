import 'package:flutter/material.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // ซ่อน AppBar
      ),
      body: Stack(
        children: [
          // เนื้อหาหลักเป็นการแสดงรายการโพสต์ด้วย ListView
          ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              const SizedBox(height: 60), // เว้นที่สำหรับช่องค้นหาด้านบน
              // ส่วนหัวเรื่องและไอคอนแจ้งเตือน
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Travel Impressions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune, color: Color(0xFF000D34)),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Color(0xFF000D34)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // สร้างการ์ดโพสต์จำลอง
              _buildPostCard(likes: 102, comments: 70, shares: 2),
              _buildPostCard(likes: 259, comments: 99, shares: 14),
              _buildPostCard(likes: 259, comments: 99, shares: 14),
              _buildPostCard(likes: 259, comments: 99, shares: 14),
            ],
          ),
          // ช่องค้นหาที่วางอยู่ด้านบน
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'search',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF000D34)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
      // ปุ่มลอยสำหรับสร้างโพสต์ใหม่
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        backgroundColor: Colors.white, // สีพื้นหลังของปุ่ม
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), // ปรับมุมให้โค้งมน
        ),
        child: const Icon(
          Icons.add,
          size: 30, // ปรับขนาดไอคอนให้เล็กลง
          color: Color(0xFF000D34), // ปรับสีไอคอนให้เข้มตามที่ต้องการ
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดง Dialog เพื่อสร้างโพสต์ใหม่
  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter post description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // ทำการบันทึกโพสต์หรือดำเนินการอื่น ๆ ที่ต้องการ
                  Navigator.pop(context); // ปิด Dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF000D34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Post'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ฟังก์ชันสำหรับสร้างการ์ดโพสต์
  Widget _buildPostCard(
      {required int likes, required int comments, required int shares}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.green, // สีพื้นหลังจำลองสำหรับรูปภาพ
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Color(0xFF000D34)),
                    const SizedBox(width: 8),
                    Text('$likes'),
                    const SizedBox(width: 16),
                    const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF000D34)),
                    const SizedBox(width: 8),
                    Text('$comments'),
                    const SizedBox(width: 16),
                    const Icon(Icons.send, color: Color(0xFF000D34)),
                    const SizedBox(width: 8),
                    Text('$shares'),
                  ],
                ),
                const Icon(Icons.bookmark_border, color: Color(0xFF000D34)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text('description or caption'),
          ),
        ],
      ),
    );
  }
}
