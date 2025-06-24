import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';

/// Use case for retrieving all chat sessions from storage
///
/// Fetches all stored chat sessions for display in the application
/// Used to show the user's conversation history
///
/// Uses [ChatHistoryRepository] for chat session retrieval operations
class GetChatSessionsUseCase {

  /// Constructor for get chat sessions use case
  ///
  /// [_repository] The chat history repository for retrieval operations
  GetChatSessionsUseCase(this._repository);
  final ChatHistoryRepository _repository;

  /// Execute the use case to get all chat sessions
  ///
  /// Retrieves all chat sessions from storage
  /// Returns a list of all [ChatSessionEntity] objects in the system
  Future<List<ChatSessionEntity>> call() {
    return _repository.getAllSessions();
  }
} 
