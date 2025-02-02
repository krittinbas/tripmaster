// lib/screens/board_page/widgets/search_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:tripmaster/page/board/board/board_controller/board_controller.dart';

class SearchBarWidget extends StatelessWidget {
  final BoardController controller;

  const SearchBarWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 16),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.searchLocations,
                decoration: const InputDecoration(
                  hintText: 'Search locations...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            if (controller.isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            else if (controller.searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 24),
                color: const Color(0xFF000D34),
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchLocations('');
                },
              )
            else
              const Icon(Icons.search, color: Color(0xFF000D34), size: 24),
          ],
        ),
      ),
    );
  }
}
