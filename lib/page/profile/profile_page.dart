import 'package:flutter/material.dart';
import 'package:tripmaster/page/profile/profile_controller/profile_controller.dart';
import 'package:tripmaster/page/profile/profile_widget/settings_page.dart';
import 'package:tripmaster/page/profile/profile_widget/edit_profile_page.dart';
import 'package:tripmaster/page/profile/profile_header/profile_header.dart';
import '../../theme/app_colors.dart';
import 'tab/my_post_tab.dart';
import 'tab/bookmark_tab.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({
    super.key,
    this.userId,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = ProfileController();
    _controller.init(widget.userId);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _controller.refreshData,
              child: _buildBody(),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: !_controller.isCurrentUser,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: _buildAppBarActions(),
    );
  }

  List<Widget>? _buildAppBarActions() {
    return _controller.isCurrentUser
        ? [
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.black,
                size: 24,
              ),
              onPressed: () => _navigateToSettings(),
            ),
            const SizedBox(width: 8),
          ]
        : null;
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
    if (mounted) {
      _controller.refreshData();
    }
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _controller.isCurrentUser ? _navigateToEditProfile : null,
          child: ProfileHeader(
            profileData: _controller.profileData,
            isCurrentUser: _controller.isCurrentUser,
            onProfileUpdated: _controller.refreshData,
          ),
        ),
        const SizedBox(height: 20),
        _buildTabs(),
        _buildTabView(),
      ],
    );
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
    if (result == true && mounted) {
      _controller.refreshData();
    }
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primaryColor,
      unselectedLabelColor: AppColors.secondaryColor,
      indicatorColor: AppColors.primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        Tab(text: _controller.isCurrentUser ? 'My post' : 'Posts'),
        Tab(text: _controller.isCurrentUser ? 'Bookmark' : 'Media'),
      ],
    );
  }

  Widget _buildTabView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          MyPostTab(userId: _controller.profileData.userId),
          BookmarkTab(userId: _controller.profileData.userId),
        ],
      ),
    );
  }
}
