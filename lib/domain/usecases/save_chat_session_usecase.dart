import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';

/// Use case for saving chat sessions to persistent storage
///
/// Stores new chat sessions or updates existing ones in the repository
/// Used to preserve conversation history for future access
///
/// Uses [ChatHistoryRepository] for chat session persistence operations
class SaveChatSessionUseCase {

  /// Constructor for save chat session use case
  ///
  /// [_repository] The chat history repository for persistence operations
  SaveChatSessionUseCase(this._repository);
  final ChatHistoryRepository _repository;

  /// Execute the use case to save a chat session
  ///
  /// Persists the provided chat session to storage
  /// [session] The [ChatSessionEntity] to save to storage
  /// Returns when the save operation is complete
  Future<void> call(ChatSessionEntity session) {
    return _repository.saveSession(session);
  }
} 
