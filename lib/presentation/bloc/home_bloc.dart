import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_chat_sessions_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetChatSessionsUseCase _getChatSessionsUseCase;

  HomeBloc(this._getChatSessionsUseCase) : super(HomeState.initial()) {
    on<LoadRecentHistoryEvent>(_onLoadRecentHistory);
    on<RefreshRecentHistoryEvent>(_onRefreshRecentHistory);
  }

  Future<void> _onLoadRecentHistory(LoadRecentHistoryEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _loadRecentSessions(emit);
  }

  Future<void> _onRefreshRecentHistory(RefreshRecentHistoryEvent event, Emitter<HomeState> emit) async {
    await _loadRecentSessions(emit);
  }

  Future<void> _loadRecentSessions(Emitter<HomeState> emit) async {
    try {
      final sessions = await _getChatSessionsUseCase.call();
      
      // Sort sessions by updated date (most recent first) and take only the first 5
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final recentSessions = sessions.take(5).toList();
      
      emit(state.copyWith(
        isLoading: false,
        recentSessions: recentSessions,
        error: null,
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }
} 