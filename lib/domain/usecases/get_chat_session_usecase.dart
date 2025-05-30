import '../entities/chat_session_entity.dart';
import '../repositories/chat_history/chat_history_repository.dart';

class GetChatSessionUseCase {
  final ChatHistoryRepository _repository;

  GetChatSessionUseCase(this._repository);

  Future<ChatSessionEntity?> call(String sessionId) {
    return _repository.getSession(sessionId);
  }
} 