part of 'chat_bloc.dart';

class ChatState {
  final LLMTextResponseEntity? generatedContent;
  final bool isLoading;
  final String? error;
  final List<types.Message> messages;
  final String? currentSessionId;
  final String? sessionTitle;
  final bool isNewSession;
  final List<ChatMessageEntity> contextMessages;
  final String? lastFailedPrompt;
  final String? partialResponse;

  ChatState({
    required this.isLoading,
    this.generatedContent,
    this.error,
    required this.messages,
    this.currentSessionId,
    this.sessionTitle,
    this.isNewSession = true,
    this.contextMessages = const [],
    this.lastFailedPrompt,
    this.partialResponse,
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
    LLMTextResponseEntity? generatedContent,
    bool? isLoading,
    String? error,
    List<types.Message>? messages,
    String? currentSessionId,
    String? sessionTitle,
    bool? isNewSession,
    List<ChatMessageEntity>? contextMessages,
    String? lastFailedPrompt,
    String? partialResponse,
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
      lastFailedPrompt: lastFailedPrompt ?? this.lastFailedPrompt,
      partialResponse: partialResponse ?? this.partialResponse,
    );
  }
}
