import '../entities/chat_session.dart';
import '../repositories/chat_history_repository.dart';

class GetChatSessionsUseCase {
  final ChatHistoryRepository _repository;

  GetChatSessionsUseCase(this._repository);

  Future<List<ChatSession>> call() {
    return _repository.getAllSessions();
  }
} 