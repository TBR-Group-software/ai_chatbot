import 'package:ai_chat_bot/presentation/widgets/chat_thinking_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_svg/svg.dart';

class ChatMessageWidget extends StatefulWidget {
  final types.Message message;
  final bool isUser;
  final bool isLoading;
  final bool isCompleted;
  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isUser,
    required this.isLoading,
    required this.isCompleted,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageText = (widget.message as types.TextMessage).text;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                mainAxisAlignment:
                    widget.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isUser)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/chat_bot_small_logo_inversed.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),

                  // if (!widget.isUser && widget.isLoading)
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.isUser
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface,
                        borderRadius:
                            widget.isUser
                                ? BorderRadius.circular(16)
                                : const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                      ),
                      child:
                          !widget.isUser &&
                                  widget.isLoading &&
                                  !widget.isCompleted &&
                                  widget.message.status == types.Status.sending
                              ? ChatThinkingWidget(
                                animationDuration: const Duration(
                                  milliseconds: 500,
                                ),
                              )
                              : Text(
                                messageText,
                                style:
                                    widget.isUser
                                        ? theme.textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                        )
                                        : theme.textTheme.bodyLarge?.copyWith(),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
