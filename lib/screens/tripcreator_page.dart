import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tripmaster/service/profile_service.dart';
import 'home_page.dart';
import 'package:tripmaster/screens/mapcreate_page.dart';
import 'package:file_picker/file_picker.dart';

class TripCreatorPage extends StatefulWidget {
  const TripCreatorPage({super.key});

  @override
  State<TripCreatorPage> createState() => _TripCreatorPageState();
}

class _TripCreatorPageState extends State<TripCreatorPage> {
  final TextEditingController _tripName = TextEditingController();
  final CollectionReference _tripcollection =
      FirebaseFirestore.instance.collection('Trips');
  final ProfileService _profileService = ProfileService();
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future<String?> _fetchUserId() async {
    final userProfile = await _profileService.getUserProfile();
    if (userProfile != null) {
      return userProfile['user_id'];
    }
    return null;
  }

  List<dynamic> plans = [];
  List<File> imageFiles = [];

  Future<void> _pickMultipleImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        final validFiles = result.paths
            .where((path) => path != null && File(path!).existsSync())
            .map((path) => File(path!))
            .toList();

        if (validFiles.isEmpty) {
          _showSnackBar('No valid images selected.');
          return;
        }

        setState(() {
          imageFiles = validFiles;
        });
      } else {
        _showSnackBar('No images selected.');
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _checkFileSize(File file) async {
    final size = await file.length();
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (size > maxSize) {
      throw Exception('File size exceeds 5MB limit');
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final compressedBytes = img.encodeJpg(image, quality: 85);
      final tempDir = await Directory.systemTemp.createTemp();
      final compressedFile = File(
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await compressedFile.writeAsBytes(compressedBytes);

      if (!compressedFile.existsSync()) {
        throw Exception('Failed to save compressed file');
      }

      return compressedFile;
    } catch (e) {
      _showSnackBar('Error compressing image: $e');
      return file;
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    final user = FirebaseAuth.instance.currentUser;

    if (imageFiles.isEmpty) {
      _showSnackBar('No images selected.');
      return [];
    }

    if (user == null) {
      _showSnackBar('User not logged in.');
      return [];
    }

    try {
      for (var i = 0; i < imageFiles.length; i++) {
        final image = imageFiles[i];

        try {
          await _checkFileSize(image);
        } catch (e) {
          _showSnackBar('Image $i is too large: $e');
          continue;
        }

        final compressedImage = await _compressImage(image);

        final extension = image.path.split('.').last;
        final fileName =
            'tripimages_${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.$extension';
        final storageRef =
            FirebaseStorage.instance.ref().child('trip_images/$fileName');
        print('Uploading to: ${storageRef.fullPath}');

        final uploadTask = storageRef.putFile(compressedImage);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Total Bytes: ${snapshot.totalBytes}');
          _showSnackBar('Uploading image $i: ${progress.toStringAsFixed(2)}%');
        });

        try {
          final snapshot = await uploadTask;
          print("Upload state: ${snapshot.state}");

          if (snapshot.state == TaskState.success) {
            final downloadUrl = await snapshot.ref.getDownloadURL();
            print("Download URL: $downloadUrl");
            imageUrls.add(downloadUrl);
          } else {
            print("Upload failed with state: ${snapshot.state}");
            throw Exception('Upload failed with state: ${snapshot.state}');
          }
        } catch (e) {
          print("Error details: $e");
          _showSnackBar('Error uploading image $i: $e');
          throw Exception('Failed to upload image $i: $e');
        }
      }
    } catch (e) {
      _showSnackBar('Error uploading images: $e');
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trip Creator'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (imageFiles.isNotEmpty)
                        ...imageFiles.map((imageFile) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: imageFile.path.startsWith('assets')
                                      ? Image.asset(
                                          imageFile.path,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(imageFile.path),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  top: -10,
                                  right: -10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        imageFiles.remove(imageFile);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 196, 196, 196),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 25),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: Size(80, 80),
                          ),
                          onPressed: () {
                            _pickMultipleImages();
                          },
                          child: const Text('+'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 8, left: 12),
              child: Text(
                "Trip's name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _tripName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length + 1,
              itemBuilder: (context, index) {
                if (index == plans.length) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          plans.add([]);
                          print("days ${plans}");
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 35),
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add Day'),
                    ),
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Day - ${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.black), // ปุ่มลบ
                            onPressed: () {
                              setState(() {
                                plans.removeAt(index);
                              });
                              print("Updated plans after delete: $plans");
                            },
                          ),
                        ],
                      ),
                      if (plans[index].isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'This day has no places added',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      Column(
                        children: plans[index].map<Widget>((place) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, top: 8, bottom: 8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/screens/dot.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place['location_name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(place['location_vicinity'] ??
                                          'No Address'),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  color: Colors.white,
                                  onSelected: (value) async {
                                    if (value == 'Edit') {
                                      final updatedPlace = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MapCreatePage(),
                                        ),
                                      );
                                      if (updatedPlace != null) {
                                        setState(() {
                                          int placeIndex =
                                              plans[index].indexOf(place);
                                          plans[index][placeIndex] =
                                              updatedPlace;
                                          print("Edited Days: $plans");
                                        });
                                      }
                                    } else if (value == 'Delete') {
                                      setState(() {
                                        plans[index].remove(place);
                                      });
                                      print("Deleteed Days: $plans");
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<String>(
                                      value: 'Edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'Delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            final selectedPlaces = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MapCreatePage(),
                              ),
                            );

                            if (selectedPlaces != null) {
                              setState(() {
                                plans[index].add(selectedPlaces);
                                print("Updated Days: $plans");
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 25),
                            textStyle: const TextStyle(fontSize: 25),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('+'),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("cancel",
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                  ),
                  onPressed: plans.any((day) => day.isEmpty)
                      ? null
                      : () async {
                          String? userId = await _fetchUserId();

                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Unable to fetch user ID')),
                            );
                            return;
                          }

                          List<String> uploadedImageUrls =
                              await _uploadImages();
                          if (uploadedImageUrls.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to upload images')),
                            );
                            return; // ถ้าไม่สามารถอัปโหลดภาพได้ จะหยุดการดำเนินการต่อ
                          }

                          for (var day in plans) {
                            for (var location in day) {
                              location['passed'] = '0';
                              var querySnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('Location')
                                  .where('location_name',
                                      isEqualTo: location['location_name'])
                                  .where('location_vicinity',
                                      isEqualTo: location['location_vicinity'])
                                  .limit(1)
                                  .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                location['location_id'] =
                                    querySnapshot.docs.first.id;
                              } else {
                                var newLocation = await FirebaseFirestore
                                    .instance
                                    .collection('Location')
                                    .add({
                                  'location_name': location['location_name'],
                                  'location_vicinity':
                                      location['location_vicinity'],
                                  'location_position':
                                      location['location_position'],
                                });

                                await newLocation.update({
                                  'location_id': newLocation.id,
                                });
                                location['location_id'] = newLocation.id;
                              }
                            }
                          }
                          plans.first[0]['passed'] = '1';

                          if (_tripName.text.isNotEmpty && plans.isNotEmpty) {
                            List<Map<String, dynamic>> TripTest =
                                plans.map((day) {
                              return {
                                'places': day,
                              };
                            }).toList();

                            try {
                              var trip2 = await _tripcollection.add({
                                'trip_name': _tripName.text,
                                'origin':
                                    plans.isNotEmpty && plans.first.isNotEmpty
                                        ? plans.first.first['location_name'] ??
                                            'No Origin'
                                        : 'No Origin',
                                'destination':
                                    plans.isNotEmpty && plans.last.isNotEmpty
                                        ? plans.last.last['location_name'] ??
                                            'No Destination'
                                        : 'No Destination',
                                'plan': TripTest,
                                'timestamp': FieldValue.serverTimestamp(),
                                'status': 'Pending',
                                'user_id': userId,
                                'uploadedImageUrls': uploadedImageUrls,
                              });
                              await trip2.update({
                                'trip_id': trip2.id,
                              });
                              print("check plantrip: $trip2");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(
                                    initialIndex: 1,
                                  ),
                                ),
                              );
                            } catch (e) {
                              print("Error adding trip: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Error saving trip')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill in all fields')),
                            );
                          }
                        },
                  child: const Text("save trip",
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }
}
