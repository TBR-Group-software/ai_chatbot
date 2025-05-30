import 'package:ai_chat_bot/core/adapters/hive_registrar.g.dart';
import 'package:ai_chat_bot/data/models/hive_chat_session.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveStorageService {
  static const String chatSessionsBox = 'chat_sessions';

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive..init(appDocumentDir.path)..registerAdapters();
    await Hive.openBox<HiveChatSession>(chatSessionsBox);
  }

  Box<HiveChatSession> get _box => Hive.box<HiveChatSession>(chatSessionsBox);

  Future<List<HiveChatSession>> getAllSessions() async {
    return _box.values.toList();
  }

  Future<HiveChatSession?> getSession(String sessionId) async {
    return _box.get(sessionId);
  }

  Future<void> saveSession(HiveChatSession session) async {
    await _box.put(session.id, session);
  }

  Future<void> deleteSession(String sessionId) async {
    await _box.delete(sessionId);
  }

  Future<void> updateSession(HiveChatSession session) async {
    await _box.put(session.id, session);
  }

  Future<void> close() async {
    await _box.close();
  }
}
