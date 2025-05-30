import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_chat_sessions_usecase.dart';
import '../../domain/repositories/chat_history_repository.dart';
import '../../domain/entities/chat_session_entity.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetChatSessionsUseCase _getChatSessionsUseCase;
  final ChatHistoryRepository _chatHistoryRepository;
  late final StreamSubscription _dataSubscription;

  HomeBloc(this._getChatSessionsUseCase, this._chatHistoryRepository)
    : super(HomeState.initial()) {
    on<LoadRecentHistoryEvent>(_onLoadRecentHistory);
    on<RefreshRecentHistoryEvent>(_onRefreshRecentHistory);
    on<DataUpdatedEvent>(_onDataUpdated);

    _dataSubscription = _chatHistoryRepository.watchAllSessions().listen((
      sessions,
    ) {
      add(DataUpdatedEvent(sessions));
    }, onError: (error) {});
  }

  Future<void> _onLoadRecentHistory(
    LoadRecentHistoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _loadRecentSessions(emit);
  }

  Future<void> _onRefreshRecentHistory(
    RefreshRecentHistoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadRecentSessions(emit);
  }

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
          error: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

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
          error: null,
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
