import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';

abstract class ChatHistoryRepository {
  Future<List<ChatSessionEntity>> getAllSessions();
  Future<ChatSessionEntity?> getSession(String sessionId);
  Future<void> saveSession(ChatSessionEntity session);
  Future<void> deleteSession(String sessionId);
  Future<void> updateSession(ChatSessionEntity session);

  Stream<List<ChatSessionEntity>> watchAllSessions();
}
