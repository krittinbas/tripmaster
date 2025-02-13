import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripmaster/models/profile_data.dart';
import 'dart:async';

class ProfileController extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  ProfileData _profileData = ProfileData.empty();
  bool _isLoading = true;
  bool _isCurrentUser = false;
  String? _currentUserId;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  ProfileData get profileData => _profileData;
  bool get isLoading => _isLoading;
  bool get isCurrentUser => _isCurrentUser;

  void init(String? userId) {
    _currentUserId = _auth.currentUser?.uid;
    _setupUserListener(userId);
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _setupUserListener(String? userId) async {
    try {
      String targetUserId;

      if (userId == null || userId.isEmpty) {
        if (_currentUserId == null) {
          _isLoading = false;
          _isCurrentUser = false;
          notifyListeners();
          return;
        }
        targetUserId = _currentUserId!;
        _isCurrentUser = true;
      } else {
        targetUserId = userId;
        _isCurrentUser = targetUserId == _currentUserId;
      }

      // Set up realtime listener
      _userSubscription = _firestore
          .collection('User')
          .doc(targetUserId)
          .snapshots()
          .listen((userDoc) {
        if (userDoc.exists) {
          _profileData = ProfileData.fromMap({
            ...userDoc.data()!,
            'user_id': targetUserId,
          });
        } else {
          _profileData = ProfileData.empty().copyWith(userId: targetUserId);
        }
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error in _setupUserListener: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    // Cancel existing subscription
    await _userSubscription?.cancel();
    // Setup new listener
    _setupUserListener(_isCurrentUser ? null : _profileData.userId);
  }
}
