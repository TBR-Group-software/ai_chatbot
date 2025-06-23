import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';

/// Use case for deleting chat sessions from storage
///
/// Permanently removes chat sessions from persistent storage
/// Used to clean up unwanted conversation history
///
/// Uses [ChatHistoryRepository] for chat session deletion operations
class DeleteChatSessionUseCase {

  /// Constructor for delete chat session use case
  ///
  /// [_repository] The chat history repository for deletion operations
  DeleteChatSessionUseCase(this._repository);
  final ChatHistoryRepository _repository;

  /// Execute the use case to delete a chat session
  ///
  /// Permanently removes the chat session with the specified ID
  /// [sessionId] The unique identifier of the chat session to delete
  /// Returns when the deletion operation is complete
  Future<void> call(String sessionId) {
    return _repository.deleteSession(sessionId);
  }
} 
