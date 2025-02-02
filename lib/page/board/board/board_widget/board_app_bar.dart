// lib/screens/board_page/widgets/board_app_bar.dart

import 'package:flutter/material.dart';
import 'package:tripmaster/page/board/board/board_controller/board_controller.dart';
import 'package:tripmaster/page/board/board/board_widget/search_bar_widget.dart';

class BoardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BoardController controller;
  final TabController tabController;
  final VoidCallback onFilterPressed;

  const BoardAppBar({
    Key? key,
    required this.controller,
    required this.tabController,
    required this.onFilterPressed,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(tabController.index == 1 ? 170 : 120);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tabController.index == 1)
              SearchBarWidget(
                controller: controller,
              ),
            const SizedBox(height: 10),
            _buildAppBarActions(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Travel Board',
          style: TextStyle(
            color: Color(0xFF000D34),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        Row(
          children: [
            if (tabController.index == 0)
              IconButton(
                icon: const Icon(Icons.tune, size: 28),
                color: const Color(0xFF000D34),
                onPressed: onFilterPressed,
              ),
            const SizedBox(width: 16),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, size: 28),
                  color: const Color(0xFF000D34),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
