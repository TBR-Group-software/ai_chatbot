import '../../domain/entities/chat_session.dart';

class HistoryState {
  final List<ChatSession> sessions;
  final List<ChatSession> filteredSessions;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  HistoryState({
    required this.sessions,
    required this.filteredSessions,
    required this.isLoading,
    this.error,
    this.searchQuery = '',
  });

  factory HistoryState.initial() => HistoryState(
        sessions: [],
        filteredSessions: [],
        isLoading: false,
        searchQuery: '',
      );

  HistoryState copyWith({
    List<ChatSession>? sessions,
    List<ChatSession>? filteredSessions,
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