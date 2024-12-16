import 'package:flutter/material.dart';

class DiscoverCard extends StatelessWidget {
  final String locationName;
  final double rating;
  final int reviews;
  final int index;
  final bool isBookmarked;
  final String?
      imageUrl; // เปลี่ยนเป็น String? เพื่อรองรับกรณีที่ imageUrl อาจเป็น null
  final VoidCallback onBookmarkPressed;

  const DiscoverCard({
    super.key,
    required this.locationName,
    required this.rating,
    required this.reviews,
    required this.index,
    required this.isBookmarked,
    required this.imageUrl, // เพิ่ม imageUrl parameter
    required this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: imageUrl != null
                        ? NetworkImage(imageUrl!)
                        : const AssetImage('assets/fallback_image.png')
                            as ImageProvider, // ใช้รูป fallback ถ้าไม่มีรูปภาพ
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color:
                        isBookmarked ? const Color(0xFF000D34) : Colors.white,
                    size: 30,
                  ),
                  onPressed: onBookmarkPressed,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF000D34),
                  ),
                  maxLines: 1, // แสดงเพียงบรรทัดเดียว
                  overflow:
                      TextOverflow.ellipsis, // ถ้าชื่อยาวเกินจะใส่ ... ต่อท้าย
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$rating',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000D34),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviews reviews)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
