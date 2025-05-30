import '../repositories/chat_history/chat_history_repository.dart';

class DeleteChatSessionUseCase {
  final ChatHistoryRepository _repository;

  DeleteChatSessionUseCase(this._repository);

  Future<void> call(String sessionId) {
    return _repository.deleteSession(sessionId);
  }
} 