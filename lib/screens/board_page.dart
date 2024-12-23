import 'package:flutter/material.dart';
import '../widgets/discover_card.dart'; // Import DiscoverCard widget
import '../widgets/post_card.dart'; // Import PostCard widget
import 'package:tripmaster/api/api_service.dart';
import '../widgets/filter_bottom_sheet/filter_bottom_sheet.dart';

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
  String selectedRating = '4.0+';
  final ApiService _apiService = ApiService();

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
        places = [];
        nextPageToken = null;
      }
    });

    await _apiService.fetchFilteredData(
      selectedCategories: selectedCategories,
      selectedRating: selectedRating,
      isPagination: isPagination,
      nextPageToken: nextPageToken,
      onPlacesFetched: (fetchedPlaces) {
        setState(() {
          places = fetchedPlaces;
          isBookmarked = List<bool>.filled(places.length, false);
          isLoading = false;
        });
      },
      onNextPageTokenFetched: (token) {
        setState(() {
          nextPageToken = token;
        });
      },
    );
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
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return FilterBottomSheet(
          selectedCategories: selectedCategories,
          selectedRating: selectedRating,
          onApplyFilters: (categories, rating) {
            setState(() {
              selectedCategories = categories;
              selectedRating = rating;
            });
            fetchFilteredData();
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
