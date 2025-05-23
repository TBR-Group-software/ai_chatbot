import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class StreamingText extends StatefulWidget {
  const StreamingText({
    super.key,
    required this.text,
    required this.animate,
    this.style,
  });
  final String text;
  final TextStyle? style;
  final bool animate;

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _previousText = '';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _previousText = widget.text;
    _initializeController();
  }

  void _initializeController() {
    try {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      _fadeAnimation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      if (!_isDisposed) {
        _controller.forward();
      }
    } catch (e) {
      debugPrint('Error initializing StreamingText controller: $e');
    }
  }

  @override
  void didUpdateWidget(final StreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _previousText = oldWidget.text;
      if (_controller.isAnimating) {
        _controller.stop();
      }
      try {
        _controller.forward(from: 0);
      } catch (e) {
        debugPrint('Error during StreamingText update: $e');
        _disposeController();
        _initializeController();
      }
    }
  }

  void _disposeController() {
    try {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      _controller.dispose();
    } catch (e) {
      debugPrint('Error disposing StreamingText controller: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.animate) {
      return GptMarkdown(widget.text, style: widget.style);
    } else {
      try {
        return AnimatedBuilder(
          animation: _controller,
          builder: (final context, final child) {
            final newText =
                widget.text.length > _previousText.length
                    ? widget.text
                    : widget.text.substring(_previousText.length);
            final textAlign = TextAlign.left;
            final textDirection = TextDirection.ltr;

            if (!_controller.isAnimating &&
                _controller.status != AnimationStatus.completed) {
              return GptMarkdown(
                widget.text,
                style: widget.style,
                textAlign: textAlign,
                textDirection: textDirection,
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_previousText.isNotEmpty)
                  Container(
                    alignment: Alignment.centerLeft,
                    width: double.infinity,
                    child: GptMarkdown(
                      _previousText,
                      style: widget.style,
                      textAlign: textAlign,
                      textDirection: textDirection,
                    ),
                  ),
                if (newText.isNotEmpty)
                  Container(
                    alignment: Alignment.centerLeft,
                    width: double.infinity,
                    child: GptMarkdown(
                      newText,
                      style: widget.style?.copyWith(
                        color: widget.style?.color?.withAlpha(
                          (_fadeAnimation.value * 255).toInt(),
                        ),
                      ),
                      textAlign: textAlign,
                      textDirection: textDirection,
                    ),
                  ),
              ],
            );
          },
        );
      } catch (e) {
        // Fallback if the animation approach fails
        debugPrint('Error in StreamingText build: $e');

        // Render text without animation as fallback

        final textAlign = TextAlign.left;
        final textDirection = TextDirection.ltr;

        return GptMarkdown(
          widget.text,
          style: widget.style,
          textAlign: textAlign,
          textDirection: textDirection,
        );
      }
    }
  }
}
