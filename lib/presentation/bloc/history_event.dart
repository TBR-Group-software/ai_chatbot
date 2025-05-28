abstract class HistoryEvent {}

class LoadHistoryEvent extends HistoryEvent {
  LoadHistoryEvent();
}

class DeleteSessionEvent extends HistoryEvent {
  final String sessionId;
  DeleteSessionEvent(this.sessionId);
}

class SearchSessionsEvent extends HistoryEvent {
  final String query;
  SearchSessionsEvent(this.query);
}

class DataUpdatedEvent extends HistoryEvent {
  // Using dynamic to match the domain entity type
  final List<dynamic> sessions;

  DataUpdatedEvent(this.sessions);
}
