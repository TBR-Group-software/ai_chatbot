part of 'chat_bloc.dart';

/// Base abstract class for all chat-related events.
///
/// This sealed class defines the contract for all events that can be
/// dispatched to the [ChatBloc]. Each concrete event represents a specific
/// user interaction or system operation within the chat interface.
///
/// All events are immutable and designed for efficient state management
/// in the BLoC architecture pattern.
abstract class ChatEvent {}

/// Event to generate AI text responses.
///
/// This event triggers the AI text generation process using the provided
/// prompt and current conversation context. It supports both initial
/// generation and retry scenarios for failed requests.
///
/// Example usage:
/// ```dart
/// // Generate response for new message
/// context.read<ChatBloc>().add(
///   GenerateTextEvent('Tell me about Flutter'),
/// );
///
/// // Retry failed generation
/// context.read<ChatBloc>().add(
///   GenerateTextEvent('Tell me about Flutter', isRetry: true),
/// );
/// ```
class GenerateTextEvent extends ChatEvent {

  /// Creates a generate text event.
  ///
  /// [prompt] The text prompt for AI response generation
  /// [isRetry] Whether this is a retry attempt (defaults to false)
  GenerateTextEvent(this.prompt, {this.isRetry = false});
  /// The text prompt to send to the AI for response generation.
  ///
  /// This should contain the user's message or query that requires
  /// an AI response. The prompt is enhanced with conversation context
  /// and relevant memory items before being sent to the LLM.
  final String prompt;

  /// Whether this is a retry attempt for a previously failed request.
  ///
  /// When true, the BLoC may use cached partial responses or apply
  /// different error handling strategies. Defaults to false for
  /// new generation requests.
  final bool isRetry;
}

/// Event to send a new message in the chat.
///
/// This event handles sending user messages, adding them to the chat
/// interface, updating conversation context, and triggering AI response
/// generation. It represents the primary user interaction in the chat.
///
/// Example usage:
/// ```dart
/// // Send user message
/// context.read<ChatBloc>().add(
///   SendMessageEvent('How does Flutter work?'),
/// );
/// ```
///
/// Empty or whitespace-only messages are ignored to prevent
/// unnecessary processing and API calls.
class SendMessageEvent extends ChatEvent {

  /// Creates a send message event.
  ///
  /// [messageText] The text content of the message to send
  SendMessageEvent(this.messageText);
  /// The text content of the message to send.
  ///
  /// This should contain the user's message content. The text will be
  /// validated (empty messages are ignored) and formatted before being
  /// added to the conversation.
  final String messageText;
}

/// Event to edit an existing message and regenerate subsequent responses.
///
/// This event allows users to modify previously sent messages and
/// automatically regenerate all subsequent conversation content.
/// This is useful for exploring different conversation paths or
/// correcting mistakes in previous messages.
///
/// Example usage:
/// ```dart
/// // Edit a previous message
/// context.read<ChatBloc>().add(
///   EditAndResendMessageEvent(
///     'message-id-123',
///     'How does Flutter state management work?',
///   ),
/// );
/// ```
class EditAndResendMessageEvent extends ChatEvent {

  /// Creates an edit and resend message event.
  ///
  /// [messageId] The unique ID of the message to edit
  /// [newMessageText] The new text content for the message
  EditAndResendMessageEvent(this.messageId, this.newMessageText);
  /// The unique identifier of the message to edit.
  ///
  /// This ID should correspond to an existing message in the chat history.
  /// If the message is not found, the event will be ignored.
  final String messageId;

  /// The new text content to replace the existing message.
  ///
  /// This will become the new content of the message, and all subsequent
  /// conversation will be regenerated based on this updated text.
  /// Empty messages are ignored.
  final String newMessageText;
}

/// Event to load an existing chat session.
///
/// This event retrieves a previously saved chat session and restores
/// its complete state including messages, context, and metadata.
/// Used when users want to continue previous conversations.
/// Example usage:
/// ```dart
/// // Load a specific chat session
/// context.read<ChatBloc>().add(
///   LoadChatSessionEvent('session-uuid-123'),
/// );
/// ```
class LoadChatSessionEvent extends ChatEvent {

  /// Creates a load chat session event.
  ///
  /// [sessionId] The unique ID of the session to load
  LoadChatSessionEvent(this.sessionId);
  /// The unique identifier of the chat session to load.
  ///
  /// This should be a valid session ID that exists in storage.
  /// If the session is not found, an error state will be emitted.
  final String sessionId;
}

/// Event to save the current chat session to persistent storage.
///
/// This event persists the current conversation state including all
/// messages, metadata, and context. Typically triggered automatically
/// after significant conversation updates or manually by user action.
/// 
/// Example usage:
/// ```dart
/// // Manually save current session
/// context.read<ChatBloc>().add(SaveChatSessionEvent());
/// ```
///
/// Auto-saving occurs after each complete AI response to ensure
/// conversation history is preserved.
class SaveChatSessionEvent extends ChatEvent {
  /// Creates a save chat session event.
  SaveChatSessionEvent();
}

/// Event to create a new chat session.
///
/// This event initializes a fresh conversation state, clearing all
/// previous messages and context while maintaining system state.
/// Used when users want to start a completely new conversation.
///
/// Example usage:
/// ```dart
/// // Start a new conversation
/// context.read<ChatBloc>().add(CreateNewSessionEvent());
/// ```
class CreateNewSessionEvent extends ChatEvent {
  /// Creates a new session event.
  CreateNewSessionEvent();
}

/// Event to retry the last failed AI generation request.
///
/// This event attempts to regenerate the AI response for the most recent
/// failed request, using any cached partial response and the original
/// prompt. Useful for handling temporary network issues or API errors.
///
/// Example usage:
/// ```dart
/// // Retry the last failed request
/// context.read<ChatBloc>().add(RetryLastRequestEvent());
/// ```
///
/// This event is only effective if there was a previous failed request
/// with cached retry information.
class RetryLastRequestEvent extends ChatEvent {
  /// Creates a retry last request event.
  RetryLastRequestEvent();
}
