part of 'home_bloc.dart';

/// Base abstract class for all home-related events
abstract class HomeEvent {}

/// Event to trigger loading of recent chat history
///
/// Initiates the loading process for recent chat sessions
/// with loading state indicators
class LoadRecentHistoryEvent extends HomeEvent {
  /// Constructor for load recent history event
  LoadRecentHistoryEvent();
}

/// Event to trigger refresh of recent chat history
///
/// Refreshes the recent chat sessions without showing
/// loading indicators (used for pull-to-refresh)
class RefreshRecentHistoryEvent extends HomeEvent {
  /// Constructor for refresh recent history event
  RefreshRecentHistoryEvent();
}

/// Internal event for handling real-time data updates
///
/// Triggered automatically when the repository stream
/// emits new chat session data
class DataUpdatedEvent extends HomeEvent {

  /// Constructor for data updated event
  ///
  /// [sessions] The updated list of chat sessions from repository
  DataUpdatedEvent(this.sessions);
  // Using dynamic to match the domain entity type
  final List<dynamic> sessions;
}
