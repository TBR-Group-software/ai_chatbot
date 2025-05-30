import '../entities/chat_session_entity.dart';
import '../repositories/chat_history_repository.dart';

class SaveChatSessionUseCase {
  final ChatHistoryRepository _repository;

  SaveChatSessionUseCase(this._repository);

  Future<void> call(ChatSessionEntity session) {
    return _repository.saveSession(session);
  }
} 