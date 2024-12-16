import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/discover_card.dart'; // Import DiscoverCard widget
import '../widgets/post_card.dart'; // Import PostCard widget
import '../widgets/filter_chip.dart'; // Import FilterChip and RatingChip

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<bool> isBookmarked = [];
  List<dynamic> places = []; // เก็บข้อมูลสถานที่จาก Google Places API
  bool isLoading = false; // ตัวแปรควบคุมสถานะโหลดเพิ่มเติม
  String? nextPageToken; // ตัวแปรสำหรับจัดการ pagination

  // ตัวแปรสำหรับเก็บค่าฟิลเตอร์
  List<String> selectedCategories = ['Restaurants', 'Hotels', 'Tourist spot'];
  String selectedRating = '4.0+'; // ค่าเริ่มต้นของ Rating เป็น 4.0+

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchFilteredData(); // เรียกข้อมูลเริ่มต้นจาก API
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับ Reset ฟิลเตอร์
  void _resetFilters() {
    setState(() {
      selectedCategories = ['Restaurants', 'Hotels', 'Tourist spot'];
      selectedRating = '4.0+'; // Reset ค่า Rating เป็น 4.0+
    });
    fetchFilteredData(); // รีเซ็ตฟิลเตอร์แล้วดึงข้อมูลใหม่
  }

  // ฟังก์ชันสำหรับ Apply ฟิลเตอร์
  void _applyFilters() {
    fetchFilteredData(); // เรียกข้อมูลจาก Google API ตามฟิลเตอร์ที่เลือก
  }

  // ฟังก์ชันสำหรับย่อข้อความ
  String truncateText(String text, {int maxLength = 20}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // ฟังก์ชันสำหรับเรียกข้อมูลจาก Google Places API
  Future<void> fetchFilteredData({bool isPagination = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (!isPagination) {
        places = []; // ล้างข้อมูลเดิมเพื่อให้แสดงผลใหม่
        nextPageToken = null; // รีเซ็ต pagination เมื่อใช้ฟิลเตอร์ใหม่
      }
    });

    const apiKey = 'AIzaSyARD6UUzTyxXJeKZrBLQX-cGFYrJ3vFcKo';
    final Map<String, String> categoryMapping = {
      'Restaurants': 'restaurant',
      'Hotels': 'lodging',
      'Tourist spot': 'tourist_attraction',
    };

    final selectedApiCategories = selectedCategories
        .map((category) => categoryMapping[category])
        .where((category) => category != null)
        .toList();

    List<dynamic> allPlaces = [];

    for (String? category in selectedApiCategories) {
      if (category == null) continue;

      final String url = nextPageToken != null && isPagination
          ? 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=$nextPageToken&key=$apiKey'
          : 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=13.736717,100.523186&radius=1500&type=$category&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final placesData = data['results'];
          nextPageToken = data['next_page_token'];

          allPlaces.addAll(placesData); // เพิ่มข้อมูลใน allPlaces
        } else {
          print('Failed to load data for category: $category');
        }
      } catch (error) {
        print('Error occurred for category $category: $error');
      }
    }

    double minRating = double.tryParse(selectedRating.replaceAll('+', '')) ?? 0;

    setState(() {
      places = allPlaces
          .where((place) =>
              place['rating'] != null && place['rating'] >= minRating)
          .toList();
      isBookmarked = List<bool>.filled(places.length, false);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          nextPageToken = null; // รีเซ็ต pagination
          await fetchFilteredData();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF000D34),
                labelColor: const Color(0xFF000D34),
                unselectedLabelColor: Colors.grey,
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Discover'),
                  Tab(text: 'Review'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDiscoverSection(),
                  _buildReviewSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 120,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildAppBarActions(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 16),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Icon(Icons.search, color: Color(0xFF000D34), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Travel Board',
          style: TextStyle(
              color: Color(0xFF000D34),
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.tune, size: 28),
              color: const Color(0xFF000D34),
              onPressed: () => _showFilterBottomSheet(context),
            ),
            const SizedBox(width: 16),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, size: 28),
                  color: const Color(0xFF000D34),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscoverSection() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            nextPageToken != null) {
          // เมื่อถึงขอบล่างสุด ให้ดึงข้อมูลเพิ่มเติม
          fetchFilteredData(isPagination: true);
          return true;
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: places.length, // จำนวนสถานที่ที่ได้จาก API
          itemBuilder: (context, index) {
            if (index >= places.length) return const SizedBox.shrink();

            final place = places[index]; // ข้อมูลสถานที่จาก API
            final String placeName = place['name'] ?? 'Unknown Place';
            final String truncatedPlaceName = truncateText(placeName);

            // ดึงรูปภาพจาก API
            String? photoReference;
            if (place['photos'] != null && place['photos'].isNotEmpty) {
              photoReference = place['photos'][0]['photo_reference'];
            }

            final String? photoUrl = photoReference != null
                ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=AIzaSyARD6UUzTyxXJeKZrBLQX-cGFYrJ3vFcKo'
                : 'https://example.com/placeholder-image.jpg'; // ถ้าไม่มีรูปให้คงเป็นพื้นสีเขียวไว้

            return DiscoverCard(
              locationName: truncatedPlaceName, // ใช้ชื่อที่ตัดให้สั้นลง
              rating: place['rating'] != null
                  ? place['rating'].toDouble()
                  : 0.0, // ตรวจสอบคะแนน
              reviews: place['user_ratings_total'] ?? 0, // ตรวจสอบจำนวนรีวิว
              imageUrl: photoUrl, // แสดงรูปถ้ามี
              isBookmarked: isBookmarked[index],
              index: index, // ส่งค่า index ให้ DiscoverCard
              onBookmarkPressed: () {
                setState(() {
                  isBookmarked[index] = !isBookmarked[index];
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: const [
            PostCard(likes: 102, comments: 70, shares: 2),
            PostCard(likes: 259, comments: 99, shares: 14),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showCreatePostDialog(context),
            backgroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.add, size: 30, color: Color(0xFF000D34)),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                  const Center(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000D34),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000D34),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomFilterChip(
                        label: 'Restaurants',
                        selected: selectedCategories.contains('Restaurants'),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedCategories.add('Restaurants');
                            } else {
                              selectedCategories.remove('Restaurants');
                            }
                          });
                        },
                      ),
                      CustomFilterChip(
                        label: 'Hotels',
                        selected: selectedCategories.contains('Hotels'),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedCategories.add('Hotels');
                            } else {
                              selectedCategories.remove('Hotels');
                            }
                          });
                        },
                      ),
                      CustomFilterChip(
                        label: 'Tourist spot',
                        selected: selectedCategories.contains('Tourist spot'),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedCategories.add('Tourist spot');
                            } else {
                              selectedCategories.remove('Tourist spot');
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000D34),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RatingChip(
                        label: '2.0+',
                        selected: selectedRating == '2.0+',
                        onSelected: (selected) {
                          setModalState(() {
                            selectedRating = selected ? '2.0+' : '';
                          });
                        },
                      ),
                      RatingChip(
                        label: '3.0+',
                        selected: selectedRating == '3.0+',
                        onSelected: (selected) {
                          setModalState(() {
                            selectedRating = selected ? '3.0+' : '';
                          });
                        },
                      ),
                      RatingChip(
                        label: '4.0+',
                        selected: selectedRating == '4.0+',
                        onSelected: (selected) {
                          setModalState(() {
                            selectedRating = selected ? '4.0+' : '';
                          });
                        },
                      ),
                      RatingChip(
                        label: '5.0',
                        selected: selectedRating == '5.0',
                        onSelected: (selected) {
                          setModalState(() {
                            selectedRating = selected ? '5.0' : '';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 168,
                        height: 47,
                        child: OutlinedButton(
                          onPressed: () {
                            _resetFilters();
                            setModalState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF000D34)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                                color: Color(0xFF000D34), fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 168,
                        height: 47,
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context); // ปิด Bottom Sheet
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000D34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000D34),
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
}
