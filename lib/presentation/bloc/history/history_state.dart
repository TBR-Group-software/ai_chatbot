part of 'history_bloc.dart';

/// State class representing the current status of chat session history.
///
/// This immutable state class manages all aspects of the chat history
/// interface including session lists, search functionality, loading states,
/// and error handling. It provides comprehensive state management for
/// displaying and interacting with chat session history.
///
/// The state supports advanced features like:
/// * **Dual Session Lists**: Maintains both complete and filtered session lists
/// * **Real-time Search**: Live filtering across session titles and content
/// * **Loading Management**: Tracks loading states for smooth UX
/// * **Error Handling**: Provides user-friendly error messages
/// * **Search State Persistence**: Remembers active search queries
/// * **Optimized Rendering**: Efficient list management for large histories
///
/// Key state components:
/// * Complete session list for data consistency
/// * Filtered session list for display optimization
/// * Search query state for UI synchronization
/// * Loading and error states for user feedback
///
/// Example usage in widgets:
/// ```dart
/// BlocBuilder<HistoryBloc, HistoryState>(
///   builder: (context, state) {
///     if (state.isLoading) {
///       return const Center(
///         child: CircularProgressIndicator(),
///       );
///     }
///     
///     if (state.error != null) {
///       return ErrorWidget(
///         message: state.error!,
///         onRetry: () => context.read<HistoryBloc>()
///           .add(LoadHistoryEvent()),
///       );
///     }
///     
///     if (state.filteredSessions.isEmpty) {
///       return EmptyHistoryWidget(
///         hasSearchQuery: state.searchQuery.isNotEmpty,
///         onClearSearch: () => context.read<HistoryBloc>()
///           .add(SearchSessionsEvent('')),
///       );
///     }
///     
///     return ListView.builder(
///       itemCount: state.filteredSessions.length,
///       itemBuilder: (context, index) {
///         final session = state.filteredSessions[index];
///         return SessionListTile(
///           session: session,
///           searchQuery: state.searchQuery,
///         );
///       },
///     );
///   },
/// )
/// ```
///
/// See also:
/// * [HistoryBloc] for state management logic
/// * [HistoryEvent] for available actions
/// * [ChatSessionEntity] for session data structure
class HistoryState {
  /// The complete list of all available chat sessions.
  ///
  /// This list contains all chat sessions loaded from the repository,
  /// sorted by update date with the most recent conversations first.
  /// It serves as the source of truth for all session data and remains
  /// unchanged during search operations.
  ///
  /// Used internally for:
  /// * Maintaining data consistency during filtering
  /// * Restoring full list when search is cleared
  /// * Providing complete context for operations
  final List<ChatSessionEntity> sessions;

  /// The filtered list of sessions for display purposes.
  ///
  /// This list contains sessions that match the current search criteria.
  /// When no search is active, it mirrors the [sessions] list. During
  /// search operations, it contains only sessions matching the query.
  ///
  /// This is the primary list used by UI components for rendering:
  /// * ListView builders use this for item count and data
  /// * Search results are immediately reflected in this list
  /// * Empty states are determined by this list's length
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
    searchQuery: '',
  );

  /// Creates a copy of this state with modified properties.
  ///
  /// This method enables immutable updates to the history state by creating
  /// a new instance with specified properties changed. Only provided
  /// parameters will be updated; all others retain their current values.
  ///
  /// This is the primary method for updating state in the BLoC pattern,
  /// ensuring immutability and predictable state transitions throughout
  /// history management operations.
  ///
  /// Example usage:
  /// ```dart
  /// // Update loading state
  /// emit(state.copyWith(isLoading: true));
  ///
  /// // Update sessions and clear errors
  /// emit(state.copyWith(
  ///   sessions: loadedSessions,
  ///   filteredSessions: loadedSessions,
  ///   isLoading: false,
  ///   error: null,
  /// ));
  ///
  /// // Update search results
  /// emit(state.copyWith(
  ///   filteredSessions: searchResults,
  ///   searchQuery: userQuery,
  /// ));
  ///
  /// // Handle errors
  /// emit(state.copyWith(
  ///   isLoading: false,
  ///   error: 'Failed to load history',
  /// ));
  /// ```
  ///
  /// Parameters (all optional):
  /// * [sessions] - New complete sessions list
  /// * [filteredSessions] - New filtered sessions list
  /// * [isLoading] - New loading status
  /// * [error] - New error message (can be null to clear)
  /// * [searchQuery] - New search query string
  ///
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
