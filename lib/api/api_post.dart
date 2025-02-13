import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/constants.dart';

class ApiService {
  Future<List<dynamic>> searchPostsByLocation(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // แปลงคำค้นหาเป็นตัวพิมพ์เล็กเพื่อให้ค้นหาได้ไม่ว่าจะพิมพ์ตัวใหญ่หรือเล็ก
      String searchLower = query.toLowerCase();

      // ค้นหา location ที่มี location_name คล้ายกับคำค้นหา
      final locationSnapshot =
          await FirebaseFirestore.instance.collection('Location').get();

      // กรองเอาเฉพาะ location ที่มีชื่อตรงกับคำค้นหาบางส่วน
      final matchedLocations = locationSnapshot.docs.where((doc) {
        String locationName =
            doc.data()['location_name'].toString().toLowerCase();
        return locationName.contains(searchLower);
      }).toList();

      final locationIds = matchedLocations.map((doc) => doc.id).toList();

      if (locationIds.isEmpty) {
        return [];
      }

      // ค้นหาโพสต์ที่มี location_id ตรงกับที่เจอ
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('Post')
          .where('location_id', whereIn: locationIds)
          .get();

      final posts = await Future.wait(postsSnapshot.docs.map((postDoc) async {
        final postData = postDoc.data();
        final locationDoc = matchedLocations.firstWhere(
          (locDoc) => locDoc.id == postData['location_id'],
        );

        return {
          ...postData,
          'location_name': locationDoc.data()['location_name'],
          'post_id': postDoc.id,
        };
      }));

      return posts;
    } catch (e) {
      print('Error searching posts by location: $e');
      return [];
    }
  }
}
