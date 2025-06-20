import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class ChatStreamingText extends StatefulWidget {
  const ChatStreamingText({
    super.key,
    required this.text,
    required this.animate,
    this.style,
  });
  final String text;
  final TextStyle? style;
  final bool animate;

  @override
  State<ChatStreamingText> createState() => _ChatStreamingTextState();
}

class _ChatStreamingTextState extends State<ChatStreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _previousText = '';
  String _displayedText = '';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _previousText = widget.text;
    _displayedText = widget.text;
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
      debugPrint('Error initializing ChatStreamingText controller: $e');
    }
  }

  @override
  void didUpdateWidget(final ChatStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      if (!widget.text.startsWith(_previousText) ||
          widget.text.length < _previousText.length) {
        _previousText = '';
        _displayedText = widget.text;
      } else {
        _previousText = oldWidget.text;
        _displayedText = widget.text;
      }

      if (_controller.isAnimating) {
        _controller.stop();
      }
      try {
        _controller.forward(from: 0);
      } catch (e) {
        debugPrint('Error during ChatStreamingText update: $e');
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
      debugPrint('Error disposing ChatStreamingText controller: $e');
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
    if (!widget.animate) {
      return GptMarkdown(widget.text, style: widget.style);
    } else {
      try {
        return AnimatedBuilder(
          animation: _controller,
          builder: (final context, final child) {
            const textAlign = TextAlign.left;

            if (!_controller.isAnimating &&
                _controller.status != AnimationStatus.completed) {
              return GptMarkdown(
                widget.text,
                style: widget.style,
                textAlign: textAlign,
              );
            }

            var newText = '';
            if (_displayedText.length > _previousText.length &&
                _displayedText.startsWith(_previousText)) {
              newText = _displayedText.substring(_previousText.length);
            } else if (_previousText.isEmpty) {
              newText = _displayedText;
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
                    ),
                  ),
                if (newText.isEmpty && _previousText.isEmpty)
                  Container(
                    alignment: Alignment.centerLeft,
                    width: double.infinity,
                    child: GptMarkdown(
                      _displayedText,
                      style: widget.style?.copyWith(
                        color: widget.style?.color?.withAlpha(
                          (_fadeAnimation.value * 255).toInt(),
                        ),
                      ),
                      textAlign: textAlign,
                    ),
                  ),
              ],
            );
          },
        );
      } catch (e) {
        debugPrint('Error in ChatStreamingText build: $e');

        const textAlign = TextAlign.left;

        return GptMarkdown(
          widget.text,
          style: widget.style,
          textAlign: textAlign,
        );
      }
    }
  }
}
