import 'package:flutter/material.dart';
import 'package:tripmaster/page/board/board/board_controller/board_controller.dart';
import 'package:tripmaster/page/board/board/board_widget/board_app_bar.dart';
import 'package:tripmaster/page/board/board/board_widget/board_content.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>
    with SingleTickerProviderStateMixin {
  late final BoardController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = BoardController(
      tabController: _tabController,
      onStateChanged: () => setState(() {}),
    );
    _controller.init();
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
      appBar: BoardAppBar(
        controller: _controller,
        tabController: _tabController,
        onFilterPressed: () => _controller.showFilterBottomSheet(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF000D34),
              labelColor: const Color(0xFF000D34),
              unselectedLabelColor: Colors.grey,
              labelStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Discover'),
                Tab(text: 'Review'),
              ],
            ),
          ),
          Expanded(
            child: BoardContent(
              controller: _controller,
              tabController: _tabController,
            ),
          ),
        ],
      ),
    );
  }
}
