part of 'chat_bloc.dart';

/// State class representing the current status of the chat interface.
///
/// This immutable state class manages all aspects of the chat conversation
/// including messages, AI responses, session management, and error handling.
/// It provides comprehensive state management for complex chat interactions
/// with AI integration and conversation persistence.
///
/// The state supports advanced features like:
/// * Real-time streaming AI responses
/// * Message editing and conversation branching
/// * Session persistence and restoration
/// * Error recovery with partial response caching
/// * Context-aware conversation management
/// * Integration with external chat UI libraries
///
/// Key state components:
/// * UI messages compatible with flutter_chat_types
/// * Domain-layer context messages for AI processing
/// * Session management and persistence tracking
/// * Error handling and retry mechanisms
/// * Loading states for various operations
///
/// Example usage in widgets:
/// ```dart
/// BlocBuilder<ChatBloc, ChatState>(
///   builder: (context, state) {
///     if (state.isLoading) {
///       return ChatLoadingIndicator();
///     }
///     
///     if (state.error != null) {
///       return ChatErrorWidget(
///         error: state.error!,
///         onRetry: () => context.read<ChatBloc>()
///           .add(RetryLastRequestEvent()),
///       );
///     }
///     
///     return ChatInterface(
///       messages: state.messages,
///       onSendMessage: (text) => context.read<ChatBloc>()
///         .add(SendMessageEvent(text)),
///       onEditMessage: (id, text) => context.read<ChatBloc>()
///         .add(EditAndResendMessageEvent(id, text)),
///     );
///   },
/// )
/// ```
///
/// See also:
/// * [ChatBloc] for state management logic
/// * [ChatEvent] for available actions
/// * [types.Message] from flutter_chat_types for UI message format
/// * [ChatMessageEntity] for domain layer message representation
class ChatState {
  /// The most recent AI-generated content response.
  ///
  /// Contains the latest response from the LLM including completion status,
  /// generated text, and metadata. Used to track response generation
  /// progress and handle streaming updates.
  ///
  /// Null when no generation is active or completed.
  final LLMTextResponseEntity? generatedContent;

  /// Whether any chat operation is currently in progress.
  ///
  /// True during message sending, AI response generation, session loading,
  /// or saving operations. Used to show loading indicators and disable
  /// user interactions during processing.
  final bool isLoading;

  /// Error message from the most recent failed operation.
  ///
  /// Contains user-friendly error information for display in the UI.
  /// Common errors include network failures, API errors, or session
  /// loading issues. Null when no error is present.
  final String? error;

  /// List of chat messages for UI display.
  ///
  /// Uses [types.Message] from flutter_chat_types for compatibility
  /// with chat UI components. Includes both user and AI messages
  /// in reverse chronological order (newest first for scrolling).
  ///
  /// Messages contain display-specific formatting and status information
  /// but may differ from [contextMessages] used for AI processing.
  final List<types.Message> messages;

  /// Unique identifier of the current chat session.
  ///
  /// Used for session persistence and restoration. Generated when
  /// creating new sessions or loaded when restoring existing ones.
  /// Null for unsaved temporary sessions.
  final String? currentSessionId;

  /// Human-readable title for the current session.
  ///
  /// Generated automatically based on conversation content or set
  /// manually. Used for session display in history lists and
  /// navigation interfaces. Null for untitled sessions.
  final String? sessionTitle;

  /// Whether this is a new unsaved session.
  ///
  /// True for fresh conversations that haven't been persisted yet.
  /// False for loaded sessions or sessions that have been saved
  /// at least once. Used to control save prompts and session UI.
  final bool isNewSession;

  /// List of messages formatted for AI context processing.
  ///
  /// Contains [ChatMessageEntity] objects structured for use with
  /// AI use cases and domain layer operations. This representation
  /// may differ from [messages] as it focuses on content and metadata
  /// needed for AI processing rather than UI display.
  ///
  /// Maintains conversation context for memory-enhanced AI responses.
  final List<ChatMessageEntity> contextMessages;

  /// The prompt that failed in the most recent error.
  ///
  /// Cached to enable retry operations without requiring the user
  /// to re-enter their request. Used by [RetryLastRequestEvent]
  /// to replay failed operations. Null when no failed prompt exists.
  final String? lastFailedPrompt;

  /// Partial AI response content from interrupted generation.
  ///
  /// Contains any text that was generated before an error or
  /// interruption occurred. Used for retry operations to continue
  /// from where generation stopped rather than starting over.
  /// Null when no partial response is cached.
  final String? partialResponse;

  /// Creates a new chat state instance.
  ///
  /// All required parameters must be provided to ensure complete
  /// state representation. Use the [initial] factory constructor
  /// for default state or [copyWith] for incremental updates.
  ///
  /// Parameters:
  /// * [isLoading] - Whether operations are in progress
  /// * [generatedContent] - Latest AI response entity (optional)
  /// * [error] - Current error message (optional)
  /// * [messages] - UI messages for display
  /// * [currentSessionId] - Current session identifier (optional)
  /// * [sessionTitle] - Human-readable session title (optional)
  /// * [isNewSession] - Whether this is an unsaved session (defaults to true)
  /// * [contextMessages] - Domain messages for AI processing (defaults to empty)
  /// * [lastFailedPrompt] - Cached failed prompt for retry (optional)
  /// * [partialResponse] - Cached partial response (optional)
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

  /// Creates the initial chat state with welcome message.
  ///
  /// This factory constructor provides the default state for new
  /// chat sessions. Includes a welcome message from the AI and
  /// sets up the basic structure for conversation.
  ///
  /// The initial state features:
  /// * Welcome message from the AI bot
  /// * No loading or error states
  /// * Empty conversation context
  /// * New session flag enabled
  /// * Ready for user interaction
  ///
  /// Returns a [ChatState] configured for starting new conversations.
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

  /// Creates a copy of this state with modified properties.
  ///
  /// This method enables immutable updates to the chat state by creating
  /// a new instance with specified properties changed. Only provided
  /// parameters will be updated; all others retain their current values.
  ///
  /// This is the primary method for updating state in the BLoC pattern,
  /// ensuring immutability and predictable state transitions throughout
  /// complex chat operations.
  ///
  /// Example usage:
  /// ```dart
  /// // Update loading state
  /// emit(state.copyWith(isLoading: true));
  ///
  /// // Add new message and clear error
  /// emit(state.copyWith(
  ///   messages: updatedMessages,
  ///   error: null,
  ///   isLoading: false,
  /// ));
  ///
  /// // Update session information
  /// emit(state.copyWith(
  ///   currentSessionId: sessionId,
  ///   sessionTitle: title,
  ///   isNewSession: false,
  /// ));
  ///
  /// // Cache failed request for retry
  /// emit(state.copyWith(
  ///   lastFailedPrompt: userPrompt,
  ///   partialResponse: partialText,
  ///   error: errorMessage,
  /// ));
  /// ```
  ///
  /// Parameters (all optional):
  /// * [generatedContent] - New AI response entity
  /// * [isLoading] - New loading status
  /// * [error] - New error message (can be null to clear)
  /// * [messages] - New UI messages list
  /// * [currentSessionId] - New session identifier
  /// * [sessionTitle] - New session title
  /// * [isNewSession] - New session status
  /// * [contextMessages] - New context messages list
  /// * [lastFailedPrompt] - New cached failed prompt
  /// * [partialResponse] - New cached partial response
  ///
  /// Returns a new [ChatState] with specified properties updated.
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
