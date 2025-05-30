import 'package:ai_chat_bot/data/models/hive_storage/hive_chat_session.dart';

/// Abstract data source for Hive Storage local operations

abstract class HiveStorageLocalDataSource {
  Future<List<HiveChatSession>> getAllSessions();

  Future<HiveChatSession?> getSession(String sessionId);

  Future<void> saveSession(HiveChatSession session);

  Future<void> deleteSession(String sessionId);

  Future<void> updateSession(HiveChatSession session);

  Future<void> close();
}
