import 'package:flutter/material.dart';
import 'package:tripmaster/page/profile/profile_widget/edit_profile_page.dart';
import 'package:tripmaster/page/profile/profile_header/profile_header_state.dart';
import 'dart:math' as math;

class ProfileHeaderUI {
  final ProfileHeaderState state;

  const ProfileHeaderUI(this.state);

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          _buildProfileInfo(),
          const SizedBox(height: 16),
          _buildActionButton(context),
          const SizedBox(height: 16),
          _buildStats(context),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileImage = state.widget.profileData.profileImage;

    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[200],
      backgroundImage:
          profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
      child: profileImage.isEmpty
          ? const Icon(Icons.person, size: 50, color: Colors.grey)
          : null,
    );
  }

  Widget _buildProfileInfo() {
    final profileData = state.widget.profileData;

    return Column(
      children: [
        if (profileData.profileName.isNotEmpty) ...[
          Text(
            profileData.profileName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          "@${profileData.username}",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        if (profileData.bio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              profileData.bio,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) => state.widget.isCurrentUser
      ? _buildEditButton(context)
      : _buildFollowButton();

  Widget _buildEditButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _handleEditProfile(context),
      icon: const Icon(
        Icons.edit,
        size: 16,
        color: Colors.black54,
      ),
      label: const Text(
        'Edit Profile',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    if (state.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    final isFollowing = state.isFollowing;
    final textColor = isFollowing ? Colors.grey[600] : Colors.black;

    return ElevatedButton.icon(
      onPressed: state.firebase.handleFollow,
      icon: Icon(
        Icons.person,
        size: 20,
        color: textColor,
      ),
      label: Text(
        isFollowing ? 'Following' : 'Follow',
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handleEditProfile(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );

    if (result == true) {
      state.widget.onProfileUpdated();
    }
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreamBuilder<int>(
          stream: state.postCountStream,
          builder: (context, snapshot) {
            return _buildStatColumn(
                context, (snapshot.data ?? 0).toString(), 'Posts');
          },
        ),
        _buildDivider(),
        _buildStatColumn(
            context, state.currentFollowers.toString(), 'Followers'),
        _buildDivider(),
        _buildStatColumn(
            context, state.currentFollowing.toString(), 'Following'),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    final numericValue = _calculateStatValue(value, label);
    final safeValue = math.max(0, numericValue).toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          safeValue,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _calculateStatValue(String value, String label) {
    if (state.widget.isCurrentUser) {
      return switch (label) {
        'Following' => state.currentFollowing,
        'Followers' => state.currentFollowers,
        _ => int.tryParse(value) ?? 0,
      };
    }

    return switch (label) {
      'Following' => state.widget.profileData.following,
      'Followers' => state.currentFollowers,
      _ => int.tryParse(value) ?? 0,
    };
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
