import 'package:flutter/material.dart';

class ChatThinkingWidget extends StatefulWidget {

  const ChatThinkingWidget({
    super.key,
    this.animationDuration = const Duration(milliseconds: 500),
  });
  final Duration animationDuration;

  @override
  State<ChatThinkingWidget> createState() => _ChatThinkingWidgetState();
}

class _ChatThinkingWidgetState extends State<ChatThinkingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration * 3,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _determineCircleColor(int circleIndex, double animationValue) {
    final theme = Theme.of(context);
    if (animationValue >= circleIndex && animationValue < circleIndex + 1) {
      return theme.colorScheme.primary;
    }
    return theme.colorScheme.onSurface;
  }

  double _determineCircleSize(int circleIndex, double animationValue) {
    if (animationValue >= circleIndex && animationValue < circleIndex + 1) {
      return 16;
    }
    return 10;
  }

  double _determineCircleOffset(int circleIndex, double animationValue) {
    if (animationValue >= circleIndex && animationValue < circleIndex + 0.5) {
      return -10.0 * (animationValue - circleIndex);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animationValue = _animation.value;

        return Row(
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              transform: Matrix4.translationValues(
                0,
                _determineCircleOffset(index, animationValue),
                0,
              ),
              decoration: BoxDecoration(
                color: _determineCircleColor(index, animationValue),
                shape: BoxShape.circle,
              ),
              width: _determineCircleSize(index, animationValue),
              height: _determineCircleSize(index, animationValue),
            );
          }),
        );
      },
    );
  }
}
