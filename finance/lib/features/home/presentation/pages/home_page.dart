import 'package:flutter/material.dart';
import 'package:finance/shared/widgets/page_template.dart';
import '../../widgets/account_card.dart';
import '../../widgets/home_page_username.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  int _selectedAccountIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      double percent = _scrollController.offset / 200;
      if (percent <= 1) {
        double offset = _scrollController.offset;
        if (percent >= 1) offset = 0;
        _animationController.value = 1 - offset / 200;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 100),
                  child: Container(
                    alignment: AlignmentDirectional.bottomStart,
                    padding:
                        const EdgeInsetsDirectional.only(start: 9, bottom: 17, end: 9),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 125,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        AccountCard(
                          title: 'N gân hàngggggggggggggg',
                          amount: 'đ530.000 VND',
                          transactions: '260 transactions',
                          color: const Color(0xFF439A97),
                          isSelected: _selectedAccountIndex == 0,
                          onTap: () {
                            setState(() {
                              _selectedAccountIndex = 0;
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        AccountCard(
                          title: 'Tín dụng',
                          amount: 'đ530.000 VND',
                          transactions: '260 transactions',
                          color: const Color(0xFF90C88E),
                          isSelected: _selectedAccountIndex == 1,
                          onTap: () {
                            setState(() {
                              _selectedAccountIndex = 1;
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        AddAccountCard(
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}