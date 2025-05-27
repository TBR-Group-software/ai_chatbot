import '../entities/chat_session.dart';
import '../repositories/chat_history_repository.dart';

class GetChatSessionUseCase {
  final ChatHistoryRepository _repository;

  GetChatSessionUseCase(this._repository);

  Future<ChatSession?> call(String sessionId) {
    return _repository.getSession(sessionId);
  }
} 