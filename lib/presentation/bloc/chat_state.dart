import 'package:ai_chat_bot/domain/entities/llm_text_response.dart';
import 'package:ai_chat_bot/domain/entities/chat_message.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatState {
  final LLMTextResponse? generatedContent;
  final bool isLoading;
  final String? error;
  final List<types.Message> messages;
  final String? currentSessionId;
  final String? sessionTitle;
  final bool isNewSession;
  final List<ChatMessage> contextMessages;

  ChatState({
    required this.isLoading,
    this.generatedContent,
    this.error,
    required this.messages,
    this.currentSessionId,
    this.sessionTitle,
    this.isNewSession = true,
    this.contextMessages = const [],
  });

  factory ChatState.initial() => ChatState(
        isLoading: false,
        messages: [
          types.TextMessage(
            author: const types.User(id: 'bot'),
            id: '1',
            text: 'Hi, can I help you?',
            status: types.Status.delivered,
          ),
        ],
        isNewSession: true,
        contextMessages: [],
      );

  ChatState copyWith({
    LLMTextResponse? generatedContent,
    bool? isLoading,
    String? error,
    List<types.Message>? messages,
    String? currentSessionId,
    String? sessionTitle,
    bool? isNewSession,
    List<ChatMessage>? contextMessages,
  }) {
    return ChatState(
      generatedContent: generatedContent ?? this.generatedContent,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      messages: messages ?? this.messages,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      isNewSession: isNewSession ?? this.isNewSession,
      contextMessages: contextMessages ?? this.contextMessages,
    );
  }
}
