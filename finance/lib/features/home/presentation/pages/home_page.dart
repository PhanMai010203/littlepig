import 'package:flutter/material.dart';
import 'package:finance/shared/widgets/page_template.dart';
import 'package:marquee/marquee.dart';
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
                        _AccountCard(
                          title: 'Ngân hàngggggggggggggg',
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
                        _AccountCard(
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
                        _AddAccountCard(
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

class _AccountCard extends StatelessWidget {
  final String title;
  final String amount;
  final String transactions;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountCard({
    required this.title,
    required this.amount,
    required this.transactions,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 170,
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 20,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const style = const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        );
                        final textPainter = TextPainter(
                          text: TextSpan(text: title, style: style),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        )..layout(maxWidth: constraints.maxWidth);

                        if (textPainter.didExceedMaxLines) {
                          return Marquee(
                            text: title,
                            style: style,
                            scrollAxis: Axis.horizontal,
                            blankSpace: 20.0,
                            velocity: 30.0,
                            pauseAfterRound: const Duration(seconds: 2),
                            fadingEdgeEndFraction: 0.1,
                            fadingEdgeStartFraction: 0.1,
                          );
                        } else {
                          return Text(title, style: style);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              amount,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              transactions,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6A6A6A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAccountCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAccountCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6A6A6A).withOpacity(0.7),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 28,
              color: Color(0xFF6A6A6A),
            ),
            SizedBox(height: 8),
            Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6A6A6A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
