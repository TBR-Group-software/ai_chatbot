import 'package:ai_chat_bot/presentation/bloc/chat_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_event.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/chat_message_widget.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatBloc _chatBloc = di.sl.get<ChatBloc>();
  final TextEditingController _messageController = TextEditingController();

  final List<types.Message> _messages = [
    types.TextMessage(
      author: const types.User(id: 'bot'),
      id: '1',
      text: 'Hi, can i help you?',
      status: types.Status.delivered,
    ),
  ];

  late FocusNode _inputFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _inputFieldFocusNode = FocusNode();
    _inputFieldFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _inputFieldFocusNode.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    _inputFieldFocusNode.unfocus();

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final userMessage = types.TextMessage(
      author: const types.User(id: 'user'),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: messageText,
    );

    final botMessage = types.TextMessage(
      author: const types.User(id: 'bot'),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      status: types.Status.sending,
    );

    setState(() {
      _messages.insert(0, userMessage);
      _messages.insert(0, botMessage);
    });

    String currentResponse = '';

    _chatBloc.add(GenerateTextEvent(messageText));

    _chatBloc.stream.listen((state) {
      if (state.generatedContent != null &&
          state.generatedContent?.text != null) {
        currentResponse += state.generatedContent!.text;
        setState(() {
          _messages[0] = types.TextMessage(
            author: const types.User(id: 'bot'),
            id: botMessage.id,
            text: currentResponse,
            status:
                state.generatedContent!.isComplete
                    ? types.Status.delivered
                    : types.Status.sending,
          );
        });
      }
    });

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
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
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
