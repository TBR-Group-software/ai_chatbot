part of 'home_bloc.dart';

/// State class for the home screen BLoC
///
/// Contains the current state of the home screen including
/// recent chat sessions, loading status, and error information
///
/// Used to manage UI state for displaying recent conversation history
class HomeState {

  /// Constructor for home state
  ///
  /// [recentSessions] List of recent chat sessions to display
  /// [isLoading] Whether the app is currently loading data
  /// [error] Error message if any operation failed
  HomeState({
    required this.recentSessions,
    required this.isLoading,
    this.error,
  });

  /// Factory constructor for initial home state
  ///
  /// Creates the initial state with empty sessions and no loading
  /// Returns a [HomeState] with default values
  factory HomeState.initial() => HomeState(
        recentSessions: [],
        isLoading: false,
      );
  final List<ChatSessionEntity> recentSessions;
  final bool isLoading;
  final String? error;

  /// Create a copy of the current state with optional modifications
  ///
  /// Allows updating specific properties while keeping others unchanged
  /// [recentSessions] New list of recent chat sessions (optional)
  /// [isLoading] New loading status (optional)
  /// [error] New error message (optional)
  /// Returns a new [HomeState] instance with updated values
  HomeState copyWith({
    List<ChatSessionEntity>? recentSessions,
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
