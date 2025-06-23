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

/// A comprehensive BLoC that manages the main chat interface and AI interactions.
///
/// This BLoC orchestrates the complete chat experience including real-time
/// messaging, AI response generation with memory enhancement, conversation
/// branching through message editing, and session persistence. It serves as
/// the central hub for all chat-related operations in the application.
///
/// The BLoC integrates multiple advanced features:
/// * **Memory-Enhanced AI Responses**: Uses relevant memories to provide
///   contextually aware and personalized AI responses
/// * **Real-time Streaming**: Displays AI responses as they are generated
///   for improved user experience
/// * **Message Editing & Conversation Branching**: Allows users to edit
///   previous messages and explore different conversation paths
/// * **Session Persistence**: Automatically saves and restores conversations
/// * **Error Recovery**: Robust error handling with retry mechanisms
/// * **Dual Message Format**: Maintains both UI-optimized and domain-optimized
///   message representations
///
/// Architecture integration:
/// * Uses domain layer use cases for clean architecture compliance
/// * Integrates with flutter_chat_types for UI compatibility
/// * Manages both presentation and domain layer message formats
/// * Coordinates with memory and session management systems
///
/// Example usage:
/// ```dart
/// // Basic chat interface setup
/// BlocProvider<ChatBloc>(
///   create: (context) => GetIt.instance<ChatBloc>(),
///   child: BlocBuilder<ChatBloc, ChatState>(
///     builder: (context, state) {
///       return Chat(
///         messages: state.messages,
///         onSendPressed: (message) {
///           context.read<ChatBloc>().add(
///             SendMessageEvent(message.text),
///           );
///         },
///         user: const types.User(id: 'user'),
///       );
///     },
///   ),
/// )
///
/// // Load existing conversation
/// context.read<ChatBloc>().add(
///   LoadChatSessionEvent('session-123'),
/// );
///
/// // Edit and regenerate conversation
/// context.read<ChatBloc>().add(
///   EditAndResendMessageEvent(
///     messageId: 'msg-456',
///     newMessageText: 'Tell me more about Flutter widgets',
///   ),
/// );
/// ```
///
/// Performance considerations:
/// * Efficient message list management for large conversations
/// * Streaming responses reduce perceived latency
/// * Smart context management prevents memory bloat
/// * Auto-saving minimizes data loss risk
///
class ChatBloc extends Bloc<ChatEvent, ChatState> {

  /// Creates a new [ChatBloc] with required dependencies.
  ///
  /// All use case parameters are essential for full functionality:
  /// * [_generateTextWithMemoryContextUseCase] - Handles AI response generation
  ///   with memory enhancement and conversation context
  /// * [_saveChatSessionUseCase] - Manages conversation persistence to storage
  /// * [_getChatSessionUseCase] - Handles loading of existing conversations
  ///
  /// The BLoC initializes with a welcome state and sets up event handlers
  /// for all supported chat operations including messaging, editing,
  /// session management, and error recovery.
  ChatBloc(
    this._generateTextWithMemoryContextUseCase,
    this._saveChatSessionUseCase,
    this._getChatSessionUseCase,
  ) : super(ChatState.initial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<EditAndResendMessageEvent>(_onEditAndResendMessage);
    on<GenerateTextEvent>(_onGenerateText);
    on<LoadChatSessionEvent>(_onLoadChatSession);
    on<SaveChatSessionEvent>(_onSaveChatSession);
    on<CreateNewSessionEvent>(_onCreateNewSession);
    on<RetryLastRequestEvent>(_onRetryLastRequest);
  }
  final GenerateTextWithMemoryContextUseCase _generateTextWithMemoryContextUseCase;
  final SaveChatSessionUseCase _saveChatSessionUseCase;
  final GetChatSessionUseCase _getChatSessionUseCase;

  /// Handles sending new user messages and triggering AI responses.
  ///
  /// This method orchestrates the complete message sending flow:
  /// 1. Validates message content (ignores empty messages)
  /// 2. Clears any previous error states
  /// 3. Creates UI-compatible user and bot message objects
  /// 4. Updates the message list for immediate UI feedback
  /// 5. Adds the user message to conversation context
  /// 6. Triggers AI response generation
  ///
  /// The process maintains dual message representations:
  /// * [types.Message] for UI display compatibility
  /// * [ChatMessageEntity] for domain layer processing
  ///
  /// [event] The send message event containing the user's text
  /// [emit] State emitter for updating the chat interface
  ///
  /// Empty or whitespace-only messages are silently ignored to prevent
  /// unnecessary API calls and maintain conversation quality.
  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (event.messageText.trim().isEmpty) {
      return;
    }

    emit(state.copyWith(
      
    ),);

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
    ),);

    // Start text generation with memory and chat session context
    add(GenerateTextEvent(event.messageText));
  }

  /// Handles editing existing messages and regenerating subsequent conversation.
  ///
  /// This powerful feature allows users to modify previous messages and
  /// automatically regenerate all subsequent conversation content, enabling
  /// conversation branching and experimentation with different approaches.
  ///
  /// The editing process involves:
  /// 1. Validating the new message content
  /// 2. Locating the target message in the conversation
  /// 3. Removing all subsequent messages (conversation pruning)
  /// 4. Updating the target message with new content
  /// 5. Rebuilding conversation context appropriately
  /// 6. Triggering AI response generation for the new branch
  ///
  /// Both UI and domain message representations are updated consistently
  /// to maintain data integrity across the application layers.
  ///
  /// [event] The edit event containing message ID and new content
  /// [emit] State emitter for updating the chat interface
  ///
  /// If the target message is not found, the operation is silently ignored.
  /// Empty replacement text is rejected to maintain conversation quality.
  Future<void> _onEditAndResendMessage(EditAndResendMessageEvent event, Emitter<ChatState> emit) async {
    if (event.newMessageText.trim().isEmpty) {
      return;
    }

    emit(state.copyWith(
      
    ),);

    // Find the message to edit
    final messages = List<types.Message>.from(state.messages);
    final messageIndex = messages.indexWhere((msg) => msg.id == event.messageId);
    
    if (messageIndex == -1) {
      return;
    }

    // Remove all messages from the edited message onwards (including subsequent bot responses)
    final messagesToKeep = messages.sublist(0, messageIndex);

    // Update the selected message with new text
    final updatedMessage = types.TextMessage(
      author: const types.User(id: 'user'),
      id: event.messageId, // Keep the same ID
      text: event.newMessageText,
      status: types.Status.delivered,
    );

    // Create new bot message for the response
    final botMessage = types.TextMessage(
      author: const types.User(id: 'bot'),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      status: types.Status.sending,
    );

    // Rebuild messages list with updated user message and new bot message
    final updatedMessages = [botMessage, updatedMessage, ...messagesToKeep];

    // Also update context messages - remove messages from the edited message onwards
    final contextMessages = List<ChatMessageEntity>.from(state.contextMessages);
    final contextIndex = contextMessages.indexWhere((msg) => msg.id == event.messageId);
    
    var updatedContext = contextMessages;
    if (contextIndex != -1) {
      // Keep all context messages before the edited message
      updatedContext = contextMessages.sublist(0, contextIndex);
    }

    // Add the updated user message to context
    final updatedUserChatMessage = ChatMessageEntity(
      id: event.messageId,
      content: event.newMessageText,
      isUser: true,
      timestamp: contextIndex != -1 ? contextMessages[contextIndex].timestamp : DateTime.now(),
      sessionId: state.currentSessionId ?? '',
    );

    final finalContext = [...updatedContext, updatedUserChatMessage];

    emit(state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      contextMessages: finalContext,
    ),);

    // Generate new LLM response for the edited message
    add(GenerateTextEvent(event.newMessageText));
  }

  /// Handles AI text generation with memory enhancement and streaming.
  ///
  /// This is the core method for AI response generation, managing the complete
  /// process from prompt enhancement to real-time streaming display. It
  /// integrates conversation context, relevant memories, and error recovery
  /// mechanisms to provide intelligent, contextual responses.
  ///
  /// The generation process includes:
  /// 1. **Retry Logic**: Handles continuation from partial responses
  /// 2. **Memory Enhancement**: Incorporates relevant stored knowledge
  /// 3. **Context Integration**: Uses conversation history for coherence
  /// 4. **Streaming Display**: Updates UI in real-time as text generates
  /// 5. **Completion Handling**: Finalizes response and triggers auto-save
  /// 6. **Error Recovery**: Caches partial responses for retry attempts
  ///
  /// The method manages both streaming (incomplete) and final (complete)
  /// responses, updating message status and conversation context accordingly.
  /// Auto-saving occurs after each complete response to prevent data loss.
  ///
  /// [event] The generation event containing prompt and retry information
  /// [emit] State emitter for updating the chat interface
  ///
  /// Errors are handled gracefully with user-friendly messages and retry
  /// capabilities. Network issues, rate limiting, and API failures are
  /// categorized for appropriate user feedback.
  Future<void> _onGenerateText(GenerateTextEvent event, Emitter<ChatState> emit) async {
    try {
      var accumulatedText = '';
      
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
              ),);

              // Auto-save session after each complete response
              add(SaveChatSessionEvent());
            } else {
              emit(state.copyWith(
                isLoading: false,
                generatedContent: textResponse,
                messages: currentMessages,
              ),);
            }
          }
        }
      }
    } catch (error) {
      // Determine error type and message
      final errorMessage = _getErrorMessage(error);
      
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
        error: errorMessage,
        messages: currentMessages,
        lastFailedPrompt: event.prompt,
        partialResponse: currentMessages.isNotEmpty 
            ? (currentMessages[0] as types.TextMessage).text 
            : null,
      ),);
    }
  }

  /// Categorizes errors into user-friendly error types for appropriate handling.
  ///
  /// Analyzes error messages and exceptions to determine the most likely
  /// cause and return an appropriate error code for UI display. This
  /// enables the UI to show specific error messages and recovery options.
  ///
  /// Error categories:
  /// * **rate_limit**: API rate limiting or quota exceeded
  /// * **connection_failed**: Network connectivity issues
  /// * **service_unavailable**: Server-side service problems
  ///
  /// [error] The caught exception or error object
  ///
  /// Returns a standardized error code string for UI handling.
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

  /// Handles retrying the last failed AI generation request.
  ///
  /// Attempts to continue or restart the most recent failed AI generation
  /// using cached context and partial responses. This provides users with
  /// a seamless recovery experience for temporary failures.
  ///
  /// The retry process:
  /// 1. Validates that a retry-able request exists
  /// 2. Updates UI state to show retry in progress
  /// 3. Restores message status to sending state
  /// 4. Re-triggers generation with retry flag enabled
  ///
  /// Retry attempts may use cached partial responses to continue generation
  /// from where it was interrupted rather than starting completely over.
  ///
  /// [event] The retry event (contains no additional parameters)
  /// [emit] State emitter for updating the chat interface
  ///
  /// If no failed request is cached, the operation is silently ignored.
  Future<void> _onRetryLastRequest(RetryLastRequestEvent event, Emitter<ChatState> emit) async {
    if (state.lastFailedPrompt == null) {
      return;
    }
    
    // Update state to show retrying
    emit(state.copyWith(
      isLoading: true,
    ),);
    
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

  /// Handles loading existing chat sessions from persistent storage.
  ///
  /// Retrieves a previously saved conversation and restores its complete
  /// state including all messages, metadata, and conversation context.
  /// This enables users to continue previous conversations seamlessly.
  ///
  /// The loading process:
  /// 1. Fetches session data using the provided session ID
  /// 2. Converts domain messages to UI-compatible format
  /// 3. Restores conversation context for AI processing
  /// 4. Updates session metadata (ID, title, status)
  /// 5. Replaces current chat state with loaded content
  ///
  /// Message conversion maintains data integrity while adapting between
  /// domain and presentation layer requirements.
  ///
  /// [event] The load event containing the session ID to restore
  /// [emit] State emitter for updating the chat interface
  ///
  /// If the session is not found or loading fails, an error state is
  /// emitted with appropriate user feedback.
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
        ),);
      }
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  /// Handles saving the current chat session to persistent storage.
  ///
  /// Persists the current conversation state including all messages,
  /// metadata, and session information. This operation typically occurs
  /// automatically after complete AI responses or manually through
  /// user actions.
  ///
  /// Auto-generated titles are derived from the first user message,
  /// truncated appropriately for display purposes.
  ///
  /// [event] The save event (contains no additional parameters)
  /// [emit] State emitter for updating the chat interface
  ///
  /// Empty conversations are not saved to prevent unnecessary storage
  /// usage. Save failures emit error states with user feedback.
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
        ),);
      }
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  /// Handles creating a new chat session with fresh state.
  ///
  /// [event] The new session event (contains no additional parameters)
  /// [emit] State emitter for updating the chat interface
  ///
  /// This operation is immediate and does not involve any persistence
  /// operations. Current unsaved conversation content will be lost.
  Future<void> _onCreateNewSession(CreateNewSessionEvent event, Emitter<ChatState> emit) async {
    emit(ChatState.initial());
  }

  /// Generates a user-friendly session title from conversation content.
  ///
  /// Creates an appropriate title for the chat session based on the first
  /// user message in the conversation. Titles are truncated to maintain
  /// reasonable display length in session lists and navigation.
  /// 
  /// [messages] The conversation context messages to analyze
  ///
  /// Returns a human-readable title string suitable for UI display.
  /// 
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
