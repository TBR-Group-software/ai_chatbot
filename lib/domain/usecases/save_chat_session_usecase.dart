import '../entities/chat_session.dart';
import '../repositories/chat_history_repository.dart';

class SaveChatSessionUseCase {
  final ChatHistoryRepository _repository;

  SaveChatSessionUseCase(this._repository);

  Future<void> call(ChatSession session) {
    return _repository.saveSession(session);
  }
} 