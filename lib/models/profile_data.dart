import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileData {
  final String userId;
  final String userTitle;
  final String username;
  final String email;
  final String userBio;
  final String profileImage;
  final int userFollower;
  final int userFollowing;
  final int userTriptaken;
  final DateTime createdAt;
  final String phoneNumber;
  final bool isBusiness;

  // getters
  String get profileName => userTitle;
  String get bio => userBio;
  int get followers => userFollower;
  int get following => userFollowing;
  int get tripsTaken => userTriptaken;
  int get posts => userTriptaken; // เพิ่ม getter นี้

  const ProfileData({
    required this.userId,
    required this.userTitle,
    required this.username,
    required this.email,
    required this.userBio,
    required this.profileImage,
    required this.userFollower,
    required this.userFollowing,
    required this.userTriptaken,
    required this.createdAt,
    required this.phoneNumber,
    required this.isBusiness,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      userId: map['user_id'] ?? '',
      userTitle: map['user_title'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      userBio: map['user_bio'] ?? '',
      profileImage: map['profile_image'] ?? '',
      userFollower: map['user_follower'] ?? 0,
      userFollowing: map['user_following'] ?? 0,
      userTriptaken: map['user_triptaken'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: map['phoneNumber'] ?? '',
      isBusiness: map['isBusiness'] ?? false,
    );
  }

  factory ProfileData.empty() {
    return ProfileData(
      userId: '',
      userTitle: '',
      username: '',
      email: '',
      userBio: '',
      profileImage: '',
      userFollower: 0,
      userFollowing: 0,
      userTriptaken: 0,
      createdAt: DateTime.now(),
      phoneNumber: '',
      isBusiness: false,
    );
  }

  ProfileData copyWith({
    String? userId,
    String? userTitle,
    String? username,
    String? email,
    String? userBio,
    String? profileImage,
    int? userFollower,
    int? userFollowing,
    int? userTriptaken,
    DateTime? createdAt,
    String? phoneNumber,
    bool? isBusiness,
  }) {
    return ProfileData(
      userId: userId ?? this.userId,
      userTitle: userTitle ?? this.userTitle,
      username: username ?? this.username,
      email: email ?? this.email,
      userBio: userBio ?? this.userBio,
      profileImage: profileImage ?? this.profileImage,
      userFollower: userFollower ?? this.userFollower,
      userFollowing: userFollowing ?? this.userFollowing,
      userTriptaken: userTriptaken ?? this.userTriptaken,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isBusiness: isBusiness ?? this.isBusiness,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_title': userTitle,
      'username': username,
      'email': email,
      'user_bio': userBio,
      'profile_image': profileImage,
      'user_follower': userFollower,
      'user_following': userFollowing,
      'user_triptaken': userTriptaken,
      'createdAt': createdAt,
      'phoneNumber': phoneNumber,
      'isBusiness': isBusiness,
    };
  }

  @override
  String toString() {
    return 'ProfileData(userId: $userId, userTitle: $userTitle, username: $username, email: $email, userBio: $userBio, profileImage: $profileImage, userFollower: $userFollower, userFollowing: $userFollowing, userTriptaken: $userTriptaken, createdAt: $createdAt, phoneNumber: $phoneNumber, isBusiness: $isBusiness)';
  }
}
