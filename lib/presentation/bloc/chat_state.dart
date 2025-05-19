import 'package:ai_chat_bot/domain/entities/llm_text_response.dart';

class ChatState {
  final LLMTextResponse? generatedContent;
  final bool isLoading;
  final String? error;
  ChatState({required this.isLoading, this.generatedContent, this.error});

  factory ChatState.initial() => ChatState(isLoading: false);

  ChatState copyWith({
    LLMTextResponse? generatedContent,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      generatedContent: generatedContent ?? this.generatedContent,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
