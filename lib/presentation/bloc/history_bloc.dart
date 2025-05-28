import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_chat_sessions_usecase.dart';
import '../../domain/usecases/delete_chat_session_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetChatSessionsUseCase _getChatSessionsUseCase;
  final DeleteChatSessionUseCase _deleteChatSessionUseCase;

  HistoryBloc(
    this._getChatSessionsUseCase,
    this._deleteChatSessionUseCase,
  ) : super(HistoryState.initial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<DeleteSessionEvent>(_onDeleteSession);
    on<SearchSessionsEvent>(_onSearchSessions);
  }

  Future<void> _onLoadHistory(LoadHistoryEvent event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final sessions = await _getChatSessionsUseCase.call();
      // Sort sessions by updated date (most recent first)
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      emit(state.copyWith(
        isLoading: false,
        sessions: sessions,
        filteredSessions: sessions,
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onDeleteSession(DeleteSessionEvent event, Emitter<HistoryState> emit) async {
    try {
      await _deleteChatSessionUseCase.call(event.sessionId);
      
      // Remove session from current state
      final updatedSessions = state.sessions.where((session) => session.id != event.sessionId).toList();
      final updatedFilteredSessions = state.filteredSessions.where((session) => session.id != event.sessionId).toList();
      
      emit(state.copyWith(
        sessions: updatedSessions,
        filteredSessions: updatedFilteredSessions,
      ));
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> _onSearchSessions(SearchSessionsEvent event, Emitter<HistoryState> emit) async {
    final query = event.query.toLowerCase();
    
    if (query.isEmpty) {
      emit(state.copyWith(
        filteredSessions: state.sessions,
        searchQuery: '',
      ));
    } else {
      final filteredSessions = state.sessions.where((session) {
        return session.title.toLowerCase().contains(query) ||
               session.messages.any((message) => message.content.toLowerCase().contains(query));
      }).toList();
      
      emit(state.copyWith(
        filteredSessions: filteredSessions,
        searchQuery: query,
      ));
    }
  }
} 