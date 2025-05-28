import '../entities/chat_session.dart';

abstract class ChatHistoryRepository {
  Future<List<ChatSession>> getAllSessions();
  Future<ChatSession?> getSession(String sessionId);
  Future<void> saveSession(ChatSession session);
  Future<void> deleteSession(String sessionId);
  Future<void> updateSession(ChatSession session);

  Stream<List<ChatSession>> watchAllSessions();
}
