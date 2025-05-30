import '../entities/chat_session_entity.dart';
import '../repositories/chat_history/chat_history_repository.dart';

class GetChatSessionsUseCase {
  final ChatHistoryRepository _repository;

  GetChatSessionsUseCase(this._repository);

  Future<List<ChatSessionEntity>> call() {
    return _repository.getAllSessions();
  }
} 