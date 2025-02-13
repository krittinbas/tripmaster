import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import '../../../../../widgets/buttons/elevated_button.dart';
import '../../../../../widgets/buttons/outlined_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_location_page.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<File> _selectedImages = [];
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isUploading = false;
  Map<String, dynamic>? _selectedLocation;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar('Please login first.');
        Navigator.pop(context);
      });
    }
  }

  Future<void> _checkFileSize(File file) async {
    final size = await file.length();
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (size > maxSize) {
      throw Exception('File size exceeds 5MB limit');
    }
  }

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
          _selectedImages = validFiles;
        });
      } else {
        _showSnackBar('No images selected.');
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e');
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

    if (_selectedImages.isEmpty) {
      _showSnackBar('No images selected.');
      return [];
    }

    if (user == null) {
      _showSnackBar('User not logged in.');
      return [];
    }

    try {
      for (var i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];

        try {
          await _checkFileSize(image);
        } catch (e) {
          _showSnackBar('Image $i is too large: $e');
          continue;
        }

        final compressedImage = await _compressImage(image);

        final extension = image.path.split('.').last;
        final fileName =
            'Post_${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.$extension';
        final storageRef =
            FirebaseStorage.instance.ref().child('Post/$fileName');

        final uploadTask = storageRef.putFile(compressedImage);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
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

  void _openLocationSearch() async {
    // สร้าง temporary post ID
    final tempPostId = FirebaseFirestore.instance.collection('Post').doc().id;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchLocationPage(postId: tempPostId),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _handleShare() async {
    if (_isUploading) return;

    final topic = _topicController.text.trim();
    final description = _descriptionController.text.trim();

    if (topic.isEmpty || description.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imageUrls = await _uploadImages();
      if (imageUrls.isEmpty) return;

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // สร้าง post document
      final postRef = FirebaseFirestore.instance.collection('Post').doc();

      // บันทึกข้อมูล post และ location ด้วย transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // บันทึกข้อมูล post
        transaction.set(postRef, {
          'post_id': postRef.id,
          'user_id': userId,
          'post_title': topic,
          'post_description': description,
          'post_image': imageUrls,
          'created_at': FieldValue.serverTimestamp(),
          'post_like': 0,
          'post_comment': 0,
          'location_id': _selectedLocation?['location_id'],
        });

        // ถ้ามีการเลือก location ให้อัพเดท document ใน Location collection
        if (_selectedLocation != null) {
          final locationRef = FirebaseFirestore.instance
              .collection('Location')
              .doc(_selectedLocation!['location_id']);

          transaction.set(locationRef, {
            'location_id': _selectedLocation!['location_id'],
            'location_name': _selectedLocation!['location_name'],
            'location_position': _selectedLocation!['location_position'],
          });
        }
      });

      _showSnackBar('Post created successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to create post: $e');
    } finally {
      Navigator.pop(context);
      setState(() {
        _isUploading = false;
      });
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

  Widget _buildImagePreview() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _selectedImages.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, color: Colors.grey, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'No images selected.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedImages.map((file) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.remove(file);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickMultipleImages,
              child: Container(
                height: 120,
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Topic', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'Enter topic here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add Location Selection
            GestureDetector(
              onTap: _openLocationSearch,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedLocation?['location_name'] ?? 'Add location',
                        style: TextStyle(
                          color: _selectedLocation != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutButton(
                  title: 'Cancel',
                  size: const Size(170, 50),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                EleButton(
                  title: 'Post',
                  size: const Size(170, 50),
                  onPressed: () {
                    if (!_isUploading) {
                      _handleShare();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
