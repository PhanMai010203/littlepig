import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget {
  const PageTemplate({
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    super.key,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      appBar: title != null ? AppBar(
        title: Text(
          title!,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: actions,
        elevation: 0,
        scrolledUnderElevation: 1,
      ) : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
} 