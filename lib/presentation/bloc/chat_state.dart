import 'package:ai_chat_bot/domain/entities/llm_text_response.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatState {
  final LLMTextResponse? generatedContent;
  final bool isLoading;
  final String? error;
  final List<types.Message> messages;

  ChatState({
    required this.isLoading,
    this.generatedContent,
    this.error,
    required this.messages,
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
      );

  ChatState copyWith({
    LLMTextResponse? generatedContent,
    bool? isLoading,
    String? error,
    List<types.Message>? messages,
  }) {
    return ChatState(
      generatedContent: generatedContent ?? this.generatedContent,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      messages: messages ?? this.messages,
    );
  }
}
