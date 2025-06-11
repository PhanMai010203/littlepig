import 'package:flutter/material.dart';
import 'package:finance/pages/homePage/homePageUsername.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    double percent = _scrollController.offset / 200;
    if (percent <= 1) {
      double offset = _scrollController.offset;
      if (percent >= 1) offset = 0;
      _animationController.value = 1 - offset / 200;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 200),
            child: Container(
              alignment: AlignmentDirectional.bottomStart,
              padding: EdgeInsetsDirectional.only(start: 9, bottom: 17, end: 9),
              child: HomePageUsername(
                animationController: _animationController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
