// lib/widgets/profile/profile_header.dart

import 'package:flutter/material.dart';
import 'package:tripmaster/models/profile_data.dart';
import 'package:tripmaster/page/profile/profile_header/profile_header_state.dart';

class ProfileHeader extends StatefulWidget {
  final ProfileData profileData;
  final bool isCurrentUser;
  final VoidCallback onProfileUpdated;

  const ProfileHeader({
    Key? key,
    required this.profileData,
    required this.isCurrentUser,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => ProfileHeaderState();
}
