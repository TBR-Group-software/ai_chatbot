import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../widgets/chat_header_widget.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/chat_message_widget.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<types.Message> _messages = [
    types.TextMessage(
      author: const types.User(id: 'bot'),
      id: '1',
      text: 'Hi, can i help you?',
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.insert(
        0,
        types.TextMessage(
          author: const types.User(id: 'user'),
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: messageText,
        ),
      );

      // Mock bot response
      _messages.insert(
        0,
        types.TextMessage(
          author: const types.User(id: 'bot'),
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'This is a mock response to: $messageText',
        ),
      );
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const ChatHeaderWidget(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageWidget(
                  message: message,
                  isUser: message.author.id != 'bot',
                );
              },
            ),
          ),
          ChatInputWidget(
            controller: _messageController,
            onSend: _handleSendMessage,
          ),
        ],
      ),
    );
  }
}
