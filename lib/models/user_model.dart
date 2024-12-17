class UserModel {
  final String email;
  final String phoneNumber;
  final String userId;

  UserModel({
    required this.email,
    required this.phoneNumber,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phonenumber': phoneNumber,
      'user_id': userId,
      'user_follower': 0,
      'user_following': 0,
    };
  }
}
