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