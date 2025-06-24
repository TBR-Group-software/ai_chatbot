import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';

/// Use case for retrieving a specific chat session by ID
///
/// Fetches a single chat session from storage using its unique identifier
/// Used to load a specific conversation for viewing or continuation
///
/// Uses [ChatHistoryRepository] for chat session retrieval operations
class GetChatSessionUseCase {

  /// Constructor for get chat session use case
  ///
  /// [_repository] The chat history repository for retrieval operations
  GetChatSessionUseCase(this._repository);
  final ChatHistoryRepository _repository;

  /// Execute the use case to get a specific chat session
  ///
  /// Retrieves a chat session by its unique identifier
  /// [sessionId] The unique ID of the chat session to retrieve
  /// Returns the [ChatSessionEntity] if found, null otherwise
  Future<ChatSessionEntity?> call(String sessionId) {
    return _repository.getSession(sessionId);
  }
} 
