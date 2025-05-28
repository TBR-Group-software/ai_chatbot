import 'package:ai_chat_bot/presentation/widgets/chat_thinking_widget.dart';
import 'package:ai_chat_bot/presentation/widgets/streaming_text.dart';
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageText = (widget.message as types.TextMessage).text;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!widget.isUser && widget.message.id == '1')
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
            child: Container(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width *
                    (widget.isUser || widget.message.id == '1' ? 0.75 : 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    widget.isUser
                        ? theme.colorScheme.primary
                        : theme.scaffoldBackgroundColor,
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
                        animationDuration: const Duration(milliseconds: 500),
                      )
                      : StreamingText(
                        text: messageText,
                        animate: !widget.isUser && !widget.isCompleted,
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
    );
  }
}
