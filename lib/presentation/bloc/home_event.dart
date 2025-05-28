abstract class HomeEvent {}

class LoadRecentHistoryEvent extends HomeEvent {
  LoadRecentHistoryEvent();
}

class RefreshRecentHistoryEvent extends HomeEvent {
  RefreshRecentHistoryEvent();
}

class DataUpdatedEvent extends HomeEvent {
  // Using dynamic to match the domain entity type
  final List<dynamic> sessions;

  DataUpdatedEvent(this.sessions);
}
