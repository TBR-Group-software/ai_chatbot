import 'package:ai_chat_bot/presentation/pages/chat/widget/chat_thinking_widget.dart';
import 'package:ai_chat_bot/presentation/pages/chat/widget/chat_streaming_text.dart';
import 'package:ai_chat_bot/presentation/pages/chat/widget/chat_retry_widget.dart';
import 'package:ai_chat_bot/presentation/pages/chat/widget/cupertino_message_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_svg/svg.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class ChatMessageWidget extends StatefulWidget {

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isUser,
    required this.isLoading,
    required this.isCompleted,
    this.onRetry,
    this.errorMessage,
    this.onEditMessage,
  });
  final types.Message message;
  final bool isUser;
  final bool isLoading;
  final bool isCompleted;
  final VoidCallback? onRetry;
  final String? errorMessage;
  final void Function(String messageId, String messageText)? onEditMessage;

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey _messageKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  Future<void> _showCupertinoDropdown() async {
    await HapticFeedback.mediumImpact();
    final messageText = (widget.message as types.TextMessage).text;

    // Create a new, highlighted instance of the bubble for the overlay
    final overlayBubble = _MessageBubble(
      message: widget.message,
      isUser: widget.isUser,
      isLoading: widget.isLoading,
      isCompleted: widget.isCompleted,
      onRetry: widget.onRetry,
      errorMessage: widget.errorMessage,
      isHighlighted: true,
    );

    CupertinoMessageDropdown.show(
      context: context,
      messageKey: _messageKey,
      layerLink: _layerLink,
      messageWidget: overlayBubble,
      isUserMessage: widget.isUser,
      messageText: messageText,
      onCopy: () {
        // Copy functionality is handled in the dropdown
      },
      onEdit:
          widget.isUser && widget.onEditMessage != null
              ? () => widget.onEditMessage!(widget.message.id, messageText)
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GlobalKey?>(
      valueListenable: CupertinoMessageDropdown.highlightNotifier,
      builder: (context, highlightedKey, child) {
        final isHighlighted = highlightedKey == _messageKey;

        // Hide the original widget if it's being shown in the overlay
        return Opacity(opacity: isHighlighted ? 0.0 : 1.0, child: child);
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onLongPress: _showCupertinoDropdown,
          // Use a key on a widget that has a render object
          child: Container(
            key: _messageKey,
            child: _MessageBubble(
              message: widget.message,
              isUser: widget.isUser,
              isLoading: widget.isLoading,
              isCompleted: widget.isCompleted,
              onRetry: widget.onRetry,
              errorMessage: widget.errorMessage,
              isHighlighted: false, // The list version is never highlighted
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isUser,
    required this.isLoading,
    required this.isCompleted,
    this.onRetry,
    this.errorMessage,
    required this.isHighlighted,
  });

  final types.Message message;
  final bool isUser;
  final bool isLoading;
  final bool isCompleted;
  final VoidCallback? onRetry;
  final String? errorMessage;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final messageText = (message as types.TextMessage).text;
    final hasError = message.status == types.Status.error;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isUser && message.id == '1')
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
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width *
                    (isUser || message.id == '1' ? 0.75 : 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    isUser
                        ? BorderRadius.circular(16)
                        : const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                // Add highlight border when message is selected
                border:
                    isHighlighted
                        ? Border.all(
                          color: Theme.of(
                            context,
                          ).extension<CustomColors>()!.primaryDim,
                          width: 2,
                        )
                        : null,
                // Add subtle shadow when highlighted
                boxShadow:
                    isHighlighted
                        ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).extension<CustomColors>()!.primaryMuted,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Builder(
                builder: (context) {
                  final theme = Theme.of(context);

                  // Show retry widget for bot messages with error status
                  if (!isUser && hasError && onRetry != null) {
                    return ChatRetryWidget(
                      errorMessage: errorMessage ?? 'connection_failed',
                      onRetry: onRetry!,
                      isRetrying: isLoading,
                    );
                  }

                  // Show retry widget for bot messages with error status (no retry available)
                  if (!isUser && hasError) {
                    return ChatRetryWidget(
                      errorMessage: errorMessage ?? 'connection_failed',
                      onRetry: () {}, // Empty callback
                    );
                  }

                  // Show thinking animation for loading bot messages
                  if (!isUser &&
                      isLoading &&
                      !isCompleted &&
                      message.status == types.Status.sending) {
                    return const ChatThinkingWidget(
                      
                    );
                  }

                  // Show regular message content
                  return ChatStreamingText(
                    text: messageText,
                    animate: !isUser && !isCompleted,
                    style:
                        isUser
                            ? theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            )
                            : theme.textTheme.bodyLarge?.copyWith(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
