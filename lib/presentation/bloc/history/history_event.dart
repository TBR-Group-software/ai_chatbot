part of 'history_bloc.dart';

/// Base abstract class for all history-related events.
///
/// This sealed class defines the contract for all events that can be
/// dispatched to the [HistoryBloc]. Each concrete event represents a specific
/// user action or system operation related to chat session history management.
///
/// All events are immutable and designed for efficient state management
/// in the BLoC architecture pattern.
///
/// See also:
/// * [LoadHistoryEvent] for loading chat session history
/// * [DeleteSessionEvent] for removing specific sessions
/// * [SearchSessionsEvent] for filtering sessions by content
/// * [DataUpdatedEvent] for handling real-time data updates
abstract class HistoryEvent {}

/// Event to load the complete chat session history.
///
/// This event triggers the initial loading of all available chat sessions
/// from persistent storage. The sessions are automatically sorted by
/// update date to present the most recent conversations first.
///
/// The loading process includes:
/// * Fetching all sessions from the repository
/// * Sorting by update timestamp (newest first)
/// * Initializing both main and filtered session lists
/// * Handling loading errors gracefully
///
/// Example usage:
/// ```dart
/// // Load history when screen initializes
/// @override
/// void initState() {
///   super.initState();
///   context.read<HistoryBloc>().add(LoadHistoryEvent());
/// }
///
/// // Refresh history manually
/// onPressed: () => context.read<HistoryBloc>()
///   .add(LoadHistoryEvent()),
/// ```
///
/// This event can be dispatched multiple times to refresh the history
/// display, making it useful for pull-to-refresh functionality.
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
///
/// The deletion process:
/// * Removes the session from persistent storage
/// * Updates the main sessions list immediately
/// * Updates the filtered sessions list to maintain search consistency
/// * Provides error feedback if the operation fails
///
/// Example usage:
/// ```dart
/// // Delete session from a list tile
/// ListTile(
///   title: Text(session.title),
///   trailing: IconButton(
///     icon: const Icon(Icons.delete),
///     onPressed: () => context.read<HistoryBloc>()
///       .add(DeleteSessionEvent(session.id)),
///   ),
/// )
///
/// // Delete with confirmation dialog
/// showDialog(
///   context: context,
///   builder: (context) => AlertDialog(
///     title: const Text('Delete Session'),
///     content: const Text('Are you sure?'),
///     actions: [
///       TextButton(
///         onPressed: () {
///           Navigator.pop(context);
///           context.read<HistoryBloc>()
///             .add(DeleteSessionEvent(sessionId));
///         },
///         child: const Text('Delete'),
///       ),
///     ],
///   ),
/// )
/// ```
class DeleteSessionEvent extends HistoryEvent {
  /// The unique identifier of the chat session to delete.
  ///
  /// This should be a valid session ID that exists in the current
  /// history. If the session doesn't exist, the operation will fail
  /// gracefully with an error message.
  final String sessionId;

  /// Creates a delete session event.
  ///
  /// [sessionId] The unique ID of the session to permanently remove
  DeleteSessionEvent(this.sessionId);
}

/// Event to search and filter chat sessions by content.
///
/// This event implements comprehensive search functionality across both
/// session titles and message content, enabling users to quickly find
/// specific conversations within their chat history.
///
/// The search functionality includes:
/// * **Title Matching**: Searches within session titles for quick identification
/// * **Content Searching**: Deep search within message content for detailed discovery
/// * **Case-Insensitive**: Flexible matching regardless of text capitalization
/// * **Real-time Filtering**: Immediate results as users type
/// * **Clear Results**: Empty query shows all sessions
///
/// Example usage:
/// ```dart
/// // Search as user types
/// TextField(
///   onChanged: (query) => context.read<HistoryBloc>()
///     .add(SearchSessionsEvent(query)),
///   decoration: const InputDecoration(
///     hintText: 'Search conversations...',
///     prefixIcon: Icon(Icons.search),
///   ),
/// )
///
/// // Search with debouncing
/// Timer? _debounce;
/// 
/// void _onSearchChanged(String query) {
///   if (_debounce?.isActive ?? false) _debounce?.cancel();
///   _debounce = Timer(const Duration(milliseconds: 500), () {
///     context.read<HistoryBloc>().add(SearchSessionsEvent(query));
///   });
/// }
///
/// // Clear search results
/// IconButton(
///   icon: const Icon(Icons.clear),
///   onPressed: () => context.read<HistoryBloc>()
///     .add(SearchSessionsEvent('')),
/// )
/// ```
class SearchSessionsEvent extends HistoryEvent {
  /// The search query to filter sessions by.
  ///
  /// This string is used to match against session titles and message
  /// content. The search is case-insensitive and supports partial matching.
  /// An empty string clears all filters and shows all sessions.
  final String query;

  /// Creates a search sessions event.
  ///
  /// [query] The search term to filter sessions by. Can be empty to clear filters.
  SearchSessionsEvent(this.query);
}

/// Event to handle real-time data updates from the repository.
///
/// This internal event is triggered automatically when the repository
/// stream detects changes in the chat session data. It ensures the UI
/// remains synchronized with any updates made by other parts of the
/// application.
///
/// The event handles:
/// * New sessions added to the repository
/// * Existing sessions updated with new messages
/// * Sessions deleted from other application parts
/// * Data consistency across the application
///
/// Example internal usage:
/// ```dart
/// // Automatically triggered by repository stream
/// _dataSubscription = repository.watchAllSessions().listen(
///   (sessions) => add(DataUpdatedEvent(sessions)),
///   onError: (error) => add(DataUpdatedEvent([])),
/// );
/// ```
///
/// This event is internal to the BLoC and should not be dispatched
/// directly from UI components.
class DataUpdatedEvent extends HistoryEvent {
  /// The updated list of chat sessions from the repository.
  ///
  /// This list contains the most current session data and is used to
  /// update both the main sessions list and apply any active search
  /// filters. The data type is dynamic to accommodate repository
  /// stream variations.
  // Using dynamic to match the domain entity type
  final List<dynamic> sessions;

  /// Creates a data updated event.
  ///
  /// [sessions] The updated session list from the repository stream
  DataUpdatedEvent(this.sessions);
}
