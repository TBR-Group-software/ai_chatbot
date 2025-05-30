import 'package:ai_chat_bot/presentation/bloc/chat_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_event.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/chat_app_bar.dart';
import 'widget/chat_input_widget.dart';
import 'widget/chat_message_widget.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.sessionId});

  final String? sessionId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatBloc _chatBloc = di.sl.get<ChatBloc>();
  final TextEditingController _messageController = TextEditingController();
  late FocusNode _inputFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _inputFieldFocusNode = FocusNode();
    _inputFieldFocusNode.requestFocus();
    
    // Load session if sessionId is provided
    if (widget.sessionId != null) {
      _chatBloc.add(LoadChatSessionEvent(widget.sessionId!));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _inputFieldFocusNode.dispose();
    _chatBloc.close();
    super.dispose();
  }

  void _handleSendMessage() {
    _inputFieldFocusNode.unfocus();

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _chatBloc.add(SendMessageEvent(messageText));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const ChatAppBar(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: BlocBuilder<ChatBloc, ChatState>(
                bloc: _chatBloc,
                builder: (context, state) {
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return ChatMessageWidget(
                        message: message,
                        isUser: message.author.id != 'bot',
                        isLoading: state.isLoading,
                        isCompleted:
                            state.generatedContent?.isComplete ?? false,
                      );
                    },
                  );
                },
              ),
            ),
            ChatInputWidget(
              focusNode: _inputFieldFocusNode,
              controller: _messageController,
              onSend: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
