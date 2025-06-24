import 'package:ai_chat_bot/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/presentation/widgets/chat_app_bar.dart';
import 'package:ai_chat_bot/presentation/pages/chat/widget/chat_input_widget.dart';
import 'package:ai_chat_bot/presentation/pages/chat/widget/chat_message_widget.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

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

  bool _isEditing = false;
  String? _editingMessageId;
  String? _originalMessageText;

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
    if (messageText.isEmpty) {
      return;
    }

    if (_isEditing && _editingMessageId != null) {
      _chatBloc.add(EditAndResendMessageEvent(_editingMessageId!, messageText));
      _cancelEdit();
    } else {
      _chatBloc.add(SendMessageEvent(messageText));
    }
    
    _messageController.clear();
  }

  void _handleEditMessage(String messageId, String messageText) {
    setState(() {
      _isEditing = true;
      _editingMessageId = messageId;
      _originalMessageText = messageText;
      _messageController.text = messageText;
    });
    
    _inputFieldFocusNode.requestFocus();
    
    // Select all text for easy editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _messageController.text.length,
      );
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingMessageId = null;
      _originalMessageText = null;
      _messageController.clear();
    });
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
                      final isBot = message.author.id == 'bot';
                      final hasError = message.status == types.Status.error;
                      final isRateLimitError = state.error == 'rate_limit';
                      
                      return ChatMessageWidget(
                        message: message,
                        isUser: !isBot,
                        isLoading: state.isLoading,
                        isCompleted: state.generatedContent?.isComplete ?? false,
                        errorMessage: state.error,
                        onRetry: (isBot && hasError && state.lastFailedPrompt != null && !isRateLimitError)
                            ? () => _chatBloc.add(RetryLastRequestEvent())
                            : null,
                        onEditMessage: !isBot ? _handleEditMessage : null,
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
              isEditing: _isEditing,
              editingHint: _originalMessageText != null 
                ? 'Editing: ${_originalMessageText!.length > 30 ? '${_originalMessageText!.substring(0, 30)}...' : _originalMessageText}'
                : null,
              onCancelEdit: _isEditing ? _cancelEdit : null,
            ),
          ],
        ),
      ),
    );
  }
}
