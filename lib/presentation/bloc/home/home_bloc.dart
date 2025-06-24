import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
part 'home_event.dart';
part 'home_state.dart';

/// BLoC for managing home screen state and recent chat sessions
///
/// Handles loading and displaying recent chat sessions on the home screen
/// Provides real-time updates when chat sessions are modified
///
/// Features:
/// - Loading recent chat sessions (limit 5)
/// - Real-time data synchronization via repository streams
/// - Automatic sorting by update date (most recent first)
/// - Error handling and loading states
///
/// Uses [GetChatSessionsUseCase] for session retrieval
/// and [ChatHistoryRepository] for real-time updates
class HomeBloc extends Bloc<HomeEvent, HomeState> {

  /// Constructor for home BLoC
  ///
  /// [_getChatSessionsUseCase] Use case for retrieving chat sessions
  /// [_chatHistoryRepository] Repository for real-time chat session updates
  HomeBloc(this._getChatSessionsUseCase, this._chatHistoryRepository)
    : super(HomeState.initial()) {
    on<LoadRecentHistoryEvent>(_onLoadRecentHistory);
    on<RefreshRecentHistoryEvent>(_onRefreshRecentHistory);
    on<DataUpdatedEvent>(_onDataUpdated);

    _dataSubscription = _chatHistoryRepository.watchAllSessions().listen((
      sessions,
    ) {
      add(DataUpdatedEvent(sessions));
    }, onError: (error) {},);
  }
  final GetChatSessionsUseCase _getChatSessionsUseCase;
  final ChatHistoryRepository _chatHistoryRepository;
  late final StreamSubscription<List<ChatSessionEntity>> _dataSubscription;

  /// Handle load recent history event
  ///
  /// Initiates loading of recent chat sessions with loading state
  /// [event] The load recent history event
  /// [emit] State emitter for updating UI state
  Future<void> _onLoadRecentHistory(
    LoadRecentHistoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _loadRecentSessions(emit);
  }

  /// Handle refresh recent history event
  ///
  /// Refreshes recent chat sessions without loading state
  /// [event] The refresh recent history event
  /// [emit] State emitter for updating UI state
  Future<void> _onRefreshRecentHistory(
    RefreshRecentHistoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadRecentSessions(emit);
  }

  /// Handle data updated event from repository stream
  ///
  /// Processes real-time updates from the chat history repository
  /// Sorts sessions and limits to 5 most recent for home display
  /// [event] The data updated event containing new session data
  /// [emit] State emitter for updating UI state
  void _onDataUpdated(DataUpdatedEvent event, Emitter<HomeState> emit) {
    try {
      // Cast to proper type and process the sessions
      final sessions = event.sessions.cast<ChatSessionEntity>();

      // Sort by updated date and take only the first 5 for home page
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final recentSessions = sessions.take(5).toList();

      emit(
        state.copyWith(
          recentSessions: recentSessions,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  /// Load recent sessions from use case
  ///
  /// Internal method to fetch and process recent chat sessions
  /// Sorts by update date and limits to 5 sessions for home display
  /// [emit] State emitter for updating UI state
  Future<void> _loadRecentSessions(Emitter<HomeState> emit) async {
    try {
      final sessions = await _getChatSessionsUseCase.call();

      // Sort sessions by updated date (most recent first) and take only the first 5
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final recentSessions = sessions.take(5).toList();

      emit(
        state.copyWith(
          isLoading: false,
          recentSessions: recentSessions,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _dataSubscription.cancel();
    return super.close();
  }
}
