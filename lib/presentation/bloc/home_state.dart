import '../../domain/entities/chat_session.dart';

class HomeState {
  final List<ChatSession> recentSessions;
  final bool isLoading;
  final String? error;

  HomeState({
    required this.recentSessions,
    required this.isLoading,
    this.error,
  });

  factory HomeState.initial() => HomeState(
        recentSessions: [],
        isLoading: false,
      );

  HomeState copyWith({
    List<ChatSession>? recentSessions,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      recentSessions: recentSessions ?? this.recentSessions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
} 