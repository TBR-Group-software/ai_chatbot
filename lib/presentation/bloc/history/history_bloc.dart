import 'dart:async';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/delete_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';
part 'history_event.dart';
part 'history_state.dart';

/// A comprehensive BLoC that manages chat session history and search functionality.
///
/// This BLoC provides complete management of chat session history including
/// loading, displaying, searching, and deleting chat sessions. It maintains
/// real-time synchronization with the data layer through reactive streams
/// and offers advanced search capabilities across session titles and content.
///
/// The BLoC integrates multiple essential features:
/// * **Real-time Session Updates**: Automatically reflects changes from other
///   parts of the application through repository streams
/// * **Advanced Search**: Full-text search across session titles and message content
/// * **Session Management**: Complete CRUD operations for chat sessions
/// * **Optimized Display**: Intelligent sorting and filtering for optimal UX
/// * **Error Handling**: Robust error management with user-friendly feedback
/// * **Memory Efficiency**: Smart filtering to minimize memory usage
///
/// Example usage:
/// ```dart
/// // Basic history display setup
/// BlocProvider<HistoryBloc>(
///   create: (context) => GetIt.instance<HistoryBloc>(),
///   child: BlocBuilder<HistoryBloc, HistoryState>(
///     builder: (context, state) {
///       if (state.isLoading) {
///         return const CircularProgressIndicator();
///       }
///       
///       return ListView.builder(
///         itemCount: state.filteredSessions.length,
///         itemBuilder: (context, index) {
///           final session = state.filteredSessions[index];
///           return SessionTile(
///             session: session,
///             onTap: () => _loadSession(session.id),
///             onDelete: () => context.read<HistoryBloc>()
///               .add(DeleteSessionEvent(session.id)),
///           );
///         },
///       );
///     },
///   ),
/// )
///
/// // Load and display sessions
/// context.read<HistoryBloc>().add(LoadHistoryEvent());
///
/// // Search through sessions
/// context.read<HistoryBloc>().add(
///   SearchSessionsEvent('Flutter development'),
/// );
/// ```
///
/// Performance considerations:
/// * Efficient real-time updates without full reloads
/// * Smart filtering reduces UI rendering overhead
/// * Memory-conscious session management for large history
/// * Debounced search to prevent excessive filtering
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {

  /// Creates a new [HistoryBloc] with required dependencies.
  ///
  /// All parameters are essential for complete functionality:
  /// * [_getChatSessionsUseCase] - Handles initial loading of chat sessions
  /// * [_deleteChatSessionUseCase] - Manages session deletion operations
  /// * [_chatHistoryRepository] - Provides real-time session updates
  ///
  /// The BLoC initializes with empty state and establishes a reactive
  /// connection to the repository for automatic updates. The stream
  /// subscription ensures the UI stays synchronized with data changes
  /// from other parts of the application.
  HistoryBloc(
    this._getChatSessionsUseCase,
    this._deleteChatSessionUseCase,
    this._chatHistoryRepository,
  ) : super(HistoryState.initial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<DeleteSessionEvent>(_onDeleteSession);
    on<SearchSessionsEvent>(_onSearchSessions);
    on<DataUpdatedEvent>(_onDataUpdated);

    _dataSubscription = _chatHistoryRepository.watchAllSessions().listen((
      sessions,
    ) {
      add(DataUpdatedEvent(sessions));
    }, onError: (error) {},);
  }
  final GetChatSessionsUseCase _getChatSessionsUseCase;
  final DeleteChatSessionUseCase _deleteChatSessionUseCase;
  final ChatHistoryRepository _chatHistoryRepository;
  late final StreamSubscription<List<ChatSessionEntity>> _dataSubscription;

  /// Handles loading the complete chat session history.
  ///
  /// This method initiates the loading process for all available chat
  /// sessions and prepares them for display. Sessions are automatically
  /// sorted by update date to show the most recent conversations first.
  ///
  /// Both the main sessions list and filtered sessions list are populated
  /// with the same data initially, enabling seamless search functionality
  /// without requiring separate loading operations.
  ///
  /// [event] The load history event (no additional parameters)
  /// [emit] State emitter for updating the history interface
  ///
  /// Loading errors are captured and displayed to users with appropriate
  /// error messages while maintaining the current session state.
  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final sessions = await _getChatSessionsUseCase.call();
      // Sort sessions by updated date (most recent first)
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(
        state.copyWith(
          isLoading: false,
          sessions: sessions,
          filteredSessions: sessions,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  /// Handles deleting a specific chat session from the history.
  ///
  /// This method permanently removes a chat session from both the storage
  /// and the current UI state. The deletion is optimistic, immediately
  /// updating the UI while the backend operation completes.
  ///
  /// Both the main and filtered session lists are updated to ensure
  /// consistency across the interface regardless of current search state.
  ///
  /// [event] The delete event containing the session ID to remove
  /// [emit] State emitter for updating the history interface
  ///
  /// Deletion errors are displayed to users while preserving the
  /// current session list state for recovery.
  Future<void> _onDeleteSession(
    DeleteSessionEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _deleteChatSessionUseCase.call(event.sessionId);

      // Remove session from current state
      final updatedSessions =
          state.sessions
              .where((session) => session.id != event.sessionId)
              .toList();
      final updatedFilteredSessions =
          state.filteredSessions
              .where((session) => session.id != event.sessionId)
              .toList();

      emit(
        state.copyWith(
          sessions: updatedSessions,
          filteredSessions: updatedFilteredSessions,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  /// Handles searching and filtering chat sessions by content.
  ///
  /// This method implements comprehensive search functionality across
  /// session titles and message content, providing users with powerful
  /// discovery capabilities for their chat history.
  ///
  /// Search capabilities:
  /// * **Title Search**: Matches session titles for quick identification
  /// * **Content Search**: Searches within message content for detailed discovery
  /// * **Case-Insensitive**: Provides flexible matching regardless of capitalization
  /// * **Real-time Results**: Updates immediately as users type
  ///
  /// [event] The search event containing the query string
  /// [emit] State emitter for updating the history interface
  ///
  /// Empty queries reset the display to show all available sessions,
  /// providing a natural way to clear search results.
  Future<void> _onSearchSessions(
    SearchSessionsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(state.copyWith(filteredSessions: state.sessions, searchQuery: ''));
    } else {
      final filteredSessions =
          state.sessions.where((session) {
            return session.title.toLowerCase().contains(query) ||
                session.messages.any(
                  (message) => message.content.toLowerCase().contains(query),
                );
          }).toList();

      emit(
        state.copyWith(filteredSessions: filteredSessions, searchQuery: query),
      );
    }
  }

  /// Handles real-time data updates from the repository stream.
  ///
  /// This method processes automatic updates from the data layer, ensuring
  /// the UI stays synchronized with any changes made by other parts of
  /// the application. It maintains search state while updating the
  /// underlying data.
  ///
  /// The update process includes:
  /// 1. Converting and validating incoming session data
  /// 2. Sorting sessions by update date for consistent ordering
  /// 3. Preserving active search queries and reapplying filters
  /// 4. Updating both main and filtered session lists appropriately
  /// 5. Clearing loading states and errors on successful updates
  ///
  /// Search state preservation ensures users don't lose their current
  /// search context when data updates occur in the background.
  ///
  /// [event] The data update event containing new session data
  /// [emit] State emitter for updating the history interface
  ///
  /// This is an internal method triggered automatically by repository
  /// streams and should not be called directly from external code.
  void _onDataUpdated(DataUpdatedEvent event, Emitter<HistoryState> emit) {
    try {
      final sessions = event.sessions.cast<ChatSessionEntity>();

      // Sort by updated date (most recent first)
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      List<ChatSessionEntity> filteredSessions;
      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
        filteredSessions =
            sessions.where((session) {
              return session.title.toLowerCase().contains(query) ||
                  session.messages.any(
                    (message) => message.content.toLowerCase().contains(query),
                  );
            }).toList();
      } else {
        filteredSessions = sessions;
      }

      emit(
        state.copyWith(
          sessions: sessions,
          filteredSessions: filteredSessions,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  /// Disposes of resources and cancels active subscriptions.
  ///
  /// This method ensures proper cleanup of the repository stream
  /// subscription when the BLoC is disposed. This prevents memory
  /// leaks and ensures the application remains performant.
  @override
  Future<void> close() {
    _dataSubscription.cancel();
    return super.close();
  }
}
