import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AccountCard extends StatelessWidget {
  final String title;
  final String amount;
  final String transactions;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

    const AccountCard({
    super.key,
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

class AddAccountCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddAccountCard({
    super.key,
    required this.onTap,
  });

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
