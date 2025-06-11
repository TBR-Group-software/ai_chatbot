import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/usecases/generate_text_with_memory_context_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/save_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/entities/chat_message_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GenerateTextWithMemoryContextUseCase _generateTextWithMemoryContextUseCase;
  final SaveChatSessionUseCase _saveChatSessionUseCase;
  final GetChatSessionUseCase _getChatSessionUseCase;

  ChatBloc(
    this._generateTextWithMemoryContextUseCase,
    this._saveChatSessionUseCase,
    this._getChatSessionUseCase,
  ) : super(ChatState.initial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<GenerateTextEvent>(_onGenerateText);
    on<LoadChatSessionEvent>(_onLoadChatSession);
    on<SaveChatSessionEvent>(_onSaveChatSession);
    on<CreateNewSessionEvent>(_onCreateNewSession);
    on<RetryLastRequestEvent>(_onRetryLastRequest);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (event.messageText.trim().isEmpty) return;

    emit(state.copyWith(
      error: null,
      lastFailedPrompt: null,
      partialResponse: null,
    ));

    final userMessage = types.TextMessage(
      author: const types.User(id: 'user'),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.messageText,
    );

    final botMessage = types.TextMessage(
      author: const types.User(id: 'bot'),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      status: types.Status.sending,
    );

    final updatedMessages = [botMessage, userMessage, ...state.messages];
    
    // Add user message to context
    final userChatMessage = ChatMessageEntity(
      id: userMessage.id,
      content: event.messageText,
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: state.currentSessionId ?? '',
    );
    
    final updatedContext = [...state.contextMessages, userChatMessage];

    emit(state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      contextMessages: updatedContext,
    ));

    // Start text generation with memory and chat session context
    add(GenerateTextEvent(event.messageText));
  }

  Future<void> _onGenerateText(GenerateTextEvent event, Emitter<ChatState> emit) async {
    try {
      String accumulatedText = '';
      
      // If this is a retry, start with the partial response
      if (event.isRetry && state.partialResponse != null) {
        accumulatedText = state.partialResponse!;
      }

      await for (final textResponse in _generateTextWithMemoryContextUseCase.call(event.prompt, state.contextMessages)) {
        if (textResponse != null && textResponse.text.isNotEmpty) {
          // Accumulate the response text
          accumulatedText += textResponse.text;
          
          // Get current bot message and update it
          final currentMessages = List<types.Message>.from(state.messages);
          if (currentMessages.isNotEmpty) {
            final currentBotMessage = currentMessages[0] as types.TextMessage;
            
            currentMessages[0] = types.TextMessage(
              author: currentBotMessage.author,
              id: currentBotMessage.id,
              text: accumulatedText,
              status: textResponse.isComplete
                  ? types.Status.delivered
                  : types.Status.sending,
            );

            // If response is complete, add bot message to context and save session
            if (textResponse.isComplete) {
              final botChatMessage = ChatMessageEntity(
                id: currentBotMessage.id,
                content: accumulatedText,
                isUser: false,
                timestamp: DateTime.now(),
                sessionId: state.currentSessionId ?? '',
              );
              
              final updatedContext = [...state.contextMessages, botChatMessage];
              
              emit(state.copyWith(
                isLoading: false,
                generatedContent: textResponse,
                messages: currentMessages,
                contextMessages: updatedContext,
                error: null,
                lastFailedPrompt: null,
                partialResponse: null,
              ));

              // Auto-save session after each complete response
              add(SaveChatSessionEvent());
            } else {
              emit(state.copyWith(
                isLoading: false,
                generatedContent: textResponse,
                messages: currentMessages,
              ));
            }
          }
        }
      }
    } catch (error) {
      // Determine error type and message
      String errorMessage = _getErrorMessage(error);
      
      // Update the bot message to show error state
      final currentMessages = List<types.Message>.from(state.messages);
      if (currentMessages.isNotEmpty) {
        final currentBotMessage = currentMessages[0] as types.TextMessage;
        currentMessages[0] = types.TextMessage(
          author: currentBotMessage.author,
          id: currentBotMessage.id,
          text: currentBotMessage.text, // Keep any partial response
          status: types.Status.error,
        );
      }
      
      emit(state.copyWith(
        isLoading: false,
        generatedContent: null,
        error: errorMessage,
        messages: currentMessages,
        lastFailedPrompt: event.prompt,
        partialResponse: currentMessages.isNotEmpty 
            ? (currentMessages[0] as types.TextMessage).text 
            : null,
      ));
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Check for 503 Service Unavailable (rate limiting)
    if (errorString.contains('503') || 
        errorString.contains('service unavailable') ||
        errorString.contains('rate limit') ||
        errorString.contains('quota') ||
        errorString.contains('exceeded')) {
      return 'rate_limit';
    }
    
    // Check for other specific error types
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return 'connection_failed';
    }
    
    // Default error
    return 'connection_failed';
  }

  Future<void> _onRetryLastRequest(RetryLastRequestEvent event, Emitter<ChatState> emit) async {
    if (state.lastFailedPrompt == null) return;
    
    // Update state to show retrying
    emit(state.copyWith(
      isLoading: true,
      error: null,
    ));
    
    // Update bot message status to show retrying
    final currentMessages = List<types.Message>.from(state.messages);
    if (currentMessages.isNotEmpty) {
      final currentBotMessage = currentMessages[0] as types.TextMessage;
      currentMessages[0] = types.TextMessage(
        author: currentBotMessage.author,
        id: currentBotMessage.id,
        text: currentBotMessage.text,
        status: types.Status.sending,
      );
      
      emit(state.copyWith(messages: currentMessages));
    }
    
    // Retry the request
    add(GenerateTextEvent(state.lastFailedPrompt!, isRetry: true));
  }

  Future<void> _onLoadChatSession(LoadChatSessionEvent event, Emitter<ChatState> emit) async {
    try {
      final session = await _getChatSessionUseCase.call(event.sessionId);
      if (session != null) {
        // Convert domain messages to UI messages
        final uiMessages = session.messages.reversed.map((msg) {
          return types.TextMessage(
            author: types.User(id: msg.isUser ? 'user' : 'bot'),
            id: msg.id,
            text: msg.content,
            status: types.Status.delivered,
          );
        }).toList();

        emit(state.copyWith(
          currentSessionId: session.id,
          sessionTitle: session.title,
          isNewSession: false,
          messages: uiMessages,
          contextMessages: session.messages,
        ));
      }
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> _onSaveChatSession(SaveChatSessionEvent event, Emitter<ChatState> emit) async {
    try {
      if (state.contextMessages.isNotEmpty) {
        final sessionId = state.currentSessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
        final title = state.sessionTitle ?? _generateSessionTitle(state.contextMessages);
        
        final session = ChatSessionEntity(
          id: sessionId,
          title: title,
          createdAt: state.isNewSession ? DateTime.now() : DateTime.now(),
          updatedAt: DateTime.now(),
          messages: state.contextMessages,
        );

        await _saveChatSessionUseCase.call(session);
        
        emit(state.copyWith(
          currentSessionId: sessionId,
          sessionTitle: title,
          isNewSession: false,
        ));
      }
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> _onCreateNewSession(CreateNewSessionEvent event, Emitter<ChatState> emit) async {
    emit(ChatState.initial());
  }

  String _generateSessionTitle(List<ChatMessageEntity> messages) {
    final firstUserMessage = messages.firstWhere(
      (msg) => msg.isUser,
      orElse: () => ChatMessageEntity(
        id: '',
        content: 'New Chat',
        isUser: true,
        timestamp: DateTime.now(),
        sessionId: '',
      ),
    );
    
    final title = firstUserMessage.content.length > 30
        ? '${firstUserMessage.content.substring(0, 30)}...'
        : firstUserMessage.content;
    
    return title.isEmpty ? 'New Chat' : title;
  }
}
