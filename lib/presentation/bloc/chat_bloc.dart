import 'package:ai_chat_bot/domain/usecases/generate_text_with_context_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/save_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/entities/chat_session.dart';
import 'package:ai_chat_bot/domain/entities/chat_message.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_event.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GenerateTextWithContextUseCase _generateTextWithContextUseCase;
  final SaveChatSessionUseCase _saveChatSessionUseCase;
  final GetChatSessionUseCase _getChatSessionUseCase;

  ChatBloc(
    this._generateTextWithContextUseCase,
    this._saveChatSessionUseCase,
    this._getChatSessionUseCase,
  ) : super(ChatState.initial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<GenerateTextEvent>(_onGenerateText);
    on<LoadChatSessionEvent>(_onLoadChatSession);
    on<SaveChatSessionEvent>(_onSaveChatSession);
    on<CreateNewSessionEvent>(_onCreateNewSession);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (event.messageText.trim().isEmpty) return;

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
    final userChatMessage = ChatMessage(
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

    // Start text generation with context
    add(GenerateTextEvent(event.messageText));
  }

  Future<void> _onGenerateText(GenerateTextEvent event, Emitter<ChatState> emit) async {
    try {
      await for (final textResponse in _generateTextWithContextUseCase.call(event.prompt, state.contextMessages)) {
        if (textResponse != null && textResponse.text.isNotEmpty) {
          // Get current bot message text and append new chunk
          final currentMessages = List<types.Message>.from(state.messages);
          if (currentMessages.isNotEmpty) {
            final currentBotMessage = currentMessages[0] as types.TextMessage;
            final updatedText = currentBotMessage.text + textResponse.text;
            
            currentMessages[0] = types.TextMessage(
              author: currentBotMessage.author,
              id: currentBotMessage.id,
              text: updatedText,
              status: textResponse.isComplete
                  ? types.Status.delivered
                  : types.Status.sending,
            );

            // If response is complete, add bot message to context and save session
            if (textResponse.isComplete) {
              final botChatMessage = ChatMessage(
                id: currentBotMessage.id,
                content: updatedText,
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
      emit(state.copyWith(
        isLoading: false,
        generatedContent: null,
        error: error.toString(),
      ));
    }
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
        
        final session = ChatSession(
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

  String _generateSessionTitle(List<ChatMessage> messages) {
    final firstUserMessage = messages.firstWhere(
      (msg) => msg.isUser,
      orElse: () => ChatMessage(
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
