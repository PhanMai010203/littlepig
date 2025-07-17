import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_text.dart';

enum SaveStatus {
  saved,
  saving,
  error,
}

class SaveStatusIndicator extends StatelessWidget {
  final SaveStatus status;
  final String? errorMessage;

  const SaveStatusIndicator({
    super.key,
    required this.status,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SaveStatus.saved:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 12,
                color: Colors.green,
              ),
              const SizedBox(width: 4),
              AppText(
                'Saved',
                fontSize: 10,
                textColor: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        );
      
      case SaveStatus.saving:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              const SizedBox(width: 4),
              AppText(
                'Saving...',
                fontSize: 10,
                textColor: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        );
      
      case SaveStatus.error:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 12,
                color: Colors.red,
              ),
              const SizedBox(width: 4),
              AppText(
                'Error',
                fontSize: 10,
                textColor: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        );
    }
  }
}

class AnimatedSaveStatusIndicator extends StatefulWidget {
  final SaveStatus status;
  final String? errorMessage;

  const AnimatedSaveStatusIndicator({
    super.key,
    required this.status,
    this.errorMessage,
  });

  @override
  State<AnimatedSaveStatusIndicator> createState() => _AnimatedSaveStatusIndicatorState();
}

class _AnimatedSaveStatusIndicatorState extends State<AnimatedSaveStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedSaveStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SaveStatusIndicator(
              status: widget.status,
              errorMessage: widget.errorMessage,
            ),
          ),
        );
      },
    );
  }
}