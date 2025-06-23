part of 'history_bloc.dart';

/// State class representing the current status of chat session history.
///
/// This immutable state class manages all aspects of the chat history
/// interface including session lists, search functionality, loading states,
/// and error handling. It provides comprehensive state management for
/// displaying and interacting with chat session history.
class HistoryState {

  /// Creates a new history state instance.
  ///
  /// All required parameters must be provided to ensure complete state
  /// representation. Use the [initial] factory constructor for default
  /// state or [copyWith] for incremental updates.
  ///
  /// Parameters:
  /// * [sessions] - Complete list of all chat sessions
  /// * [filteredSessions] - Filtered list for display purposes
  /// * [isLoading] - Whether loading operations are in progress
  /// * [error] - Current error message (optional)
  /// * [searchQuery] - Active search query string (defaults to empty)
  HistoryState({
    required this.sessions,
    required this.filteredSessions,
    required this.isLoading,
    this.error,
    this.searchQuery = '',
  });

  /// Creates the initial history state with empty data.
  ///
  /// This factory constructor provides the default state for new
  /// history instances. All lists are empty, loading is false,
  /// and no search query or error is present.
  ///
  /// The initial state represents:
  /// * No sessions loaded yet
  /// * No active search or filtering
  /// * Ready for loading operations
  /// * Clean error state
  ///
  /// Returns a [HistoryState] configured for initial use.
  factory HistoryState.initial() => HistoryState(
    sessions: [],
    filteredSessions: [],
    isLoading: false,
  );
  /// The complete list of all available chat sessions.
  ///
  /// This list contains all chat sessions loaded from the repository,
  /// sorted by update date with the most recent conversations first.
  /// It serves as the source of truth for all session data and remains
  /// unchanged during search operations.
  final List<ChatSessionEntity> sessions;

  /// The filtered list of sessions for display purposes.
  ///
  /// This list contains sessions that match the current search criteria.
  /// When no search is active, it mirrors the [sessions] list. During
  /// search operations, it contains only sessions matching the query.
  final List<ChatSessionEntity> filteredSessions;

  /// Whether a history loading operation is currently in progress.
  ///
  /// True during initial history loading or manual refresh operations.
  /// Used to display loading indicators and prevent user interactions
  /// that might interfere with the loading process.
  ///
  /// Loading states:
  /// * Initial app launch loading
  /// * Manual refresh operations
  /// * Error recovery reloading
  final bool isLoading;

  /// Error message from the most recent failed operation.
  ///
  /// Contains user-friendly error information when history operations
  /// fail. Common errors include network failures, storage access issues,
  /// or permission problems. Null when no error is present.
  ///
  /// Error types:
  /// * History loading failures
  /// * Session deletion errors
  /// * Data synchronization issues
  final String? error;

  /// The currently active search query string.
  ///
  /// Contains the text being used to filter sessions. Empty when no
  /// search is active. This value is preserved during data updates
  /// to maintain search context across real-time synchronization.
  ///
  /// Search query features:
  /// * Case-insensitive matching
  /// * Searches both titles and message content
  /// * Preserved during background data updates
  /// * Used for search result highlighting
  final String searchQuery;

  /// Creates a copy of this state with modified properties.
  /// Returns a new [HistoryState] with specified properties updated.
  HistoryState copyWith({
    List<ChatSessionEntity>? sessions,
    List<ChatSessionEntity>? filteredSessions,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return HistoryState(
      sessions: sessions ?? this.sessions,
      filteredSessions: filteredSessions ?? this.filteredSessions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
