// lib/screens/board_page/widgets/board_content.dart

import 'package:flutter/material.dart';
import 'package:tripmaster/page/board/board/board_controller/board_controller.dart';
import 'package:tripmaster/page/board/discover/detail_discover.dart';
import 'package:tripmaster/page/board/discover/discover.dart';
import 'package:tripmaster/page/board/review/review.dart';
import 'package:tripmaster/widgets/card/post_card.dart';

class BoardContent extends StatelessWidget {
  final BoardController controller;
  final TabController tabController;

  const BoardContent({
    Key? key,
    required this.controller,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tabController.index == 1 &&
        controller.searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }

    return TabBarView(
      controller: tabController,
      children: [
        DiscoverSection(
          places: controller.places,
          isLoading: controller.isLoading,
          nextPageToken: controller.nextPageToken,
          isBookmarked: controller.isBookmarked,
          fetchFilteredData: controller.fetchFilteredData,
          onCardTap: (place) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(place: place),
              ),
            );
          },
          apiService: controller.discoverApiService,
        ),
        const ReviewSection(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.searchResults.isEmpty) {
      return const Center(
        child: Text('No locations found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final post = controller.searchResults[index];
        return PostCard(
          likes: post['post_like'] ?? 0,
          comments: post['post_comment'] ?? 0,
          shares: post['post_share'] ?? 0,
          topic: post['post_title'] ?? 'Untitled',
          imageUrls: List<String>.from(post['post_image'] ?? []),
          userId: post['user_id'] ?? '',
          username: post['username'] ?? 'Anonymous',
          location: post['location_name'] ?? 'Unknown location',
          description: post['post_description'] ?? '',
          postId: post['post_id'],
          isLiked: false,
          isBookmarked: false,
          onLikePressed: () {},
          onBookmarkPressed: () {},
          onMorePressed: () {},
        );
      },
    );
  }
}
