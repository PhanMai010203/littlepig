import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomePageUsername extends StatelessWidget {
  final AnimationController animationController;

  const HomePageUsername({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (_, child) {
        return Transform.scale(
          alignment: AlignmentDirectional.bottomStart,
          scale: animationController.value < 0.5
              ? 0.5 * 0.4 + 0.6
              : (animationController.value) * 0.4 + 0.6,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 9),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Text(
            "navigation.home".tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
          ),
        ),
      ),
    );
  }
}
