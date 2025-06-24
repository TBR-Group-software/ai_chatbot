part of 'history_bloc.dart';

/// Base abstract class for all history-related events.
///
/// This sealed class defines the contract for all events that can be
/// dispatched to the [HistoryBloc]. Each concrete event represents a specific
/// user action or system operation related to chat session history management.
///
/// All events are immutable and designed for efficient state management
/// in the BLoC architecture pattern.
abstract class HistoryEvent {}

/// Event to load the complete chat session history.
///
/// This event triggers the initial loading of all available chat sessions
/// from persistent storage. The sessions are automatically sorted by
/// update date to present the most recent conversations first.
class LoadHistoryEvent extends HistoryEvent {
  /// Creates a load history event.
  ///
  /// No parameters are required as this event loads all available
  /// chat sessions from the repository.
  LoadHistoryEvent();
}

/// Event to delete a specific chat session from the history.
///
/// This event permanently removes a chat session from both persistent
/// storage and the current UI state. The deletion is optimistic,
/// immediately updating the interface while the storage operation completes.
class DeleteSessionEvent extends HistoryEvent {

  /// Creates a delete session event.
  ///
  /// [sessionId] The unique ID of the session to permanently remove
  DeleteSessionEvent(this.sessionId);
  /// The unique identifier of the chat session to delete.
  ///
  /// This should be a valid session ID that exists in the current
  /// history. If the session doesn't exist, the operation will fail
  /// gracefully with an error message.
  final String sessionId;
}

/// Event to search and filter chat sessions by content.
///
/// This event implements comprehensive search functionality across both
/// session titles and message content, enabling users to quickly find
/// specific conversations within their chat history.
class SearchSessionsEvent extends HistoryEvent {

  /// Creates a search sessions event.
  ///
  /// [query] The search term to filter sessions by. Can be empty to clear filters.
  SearchSessionsEvent(this.query);
  /// The search query to filter sessions by.
  ///
  /// This string is used to match against session titles and message
  /// content. The search is case-insensitive and supports partial matching.
  /// An empty string clears all filters and shows all sessions.
  final String query;
}

/// Event to handle real-time data updates from the repository.
///
/// This internal event is triggered automatically when the repository
/// stream detects changes in the chat session data. It ensures the UI
/// remains synchronized with any updates made by other parts of the
/// application.
class DataUpdatedEvent extends HistoryEvent {

  /// Creates a data updated event.
  ///
  /// [sessions] The updated session list from the repository stream
  DataUpdatedEvent(this.sessions);
  /// The updated list of chat sessions from the repository.
  ///
  /// This list contains the most current session data and is used to
  /// update both the main sessions list and apply any active search
  /// filters. The data type is dynamic to accommodate repository
  /// stream variations.
  // Using dynamic to match the domain entity type
  final List<dynamic> sessions;
}
