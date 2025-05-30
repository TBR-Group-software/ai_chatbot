import 'package:ai_chat_bot/core/adapters/hive_registrar.g.dart';
import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_chat_session.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

class ImplHiveStorageLocalDataSource implements HiveStorageLocalDataSource {
  static const String chatSessionsBox = 'chat_sessions';

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive..init(appDocumentDir.path)..registerAdapters();
    await Hive.openBox<HiveChatSession>(chatSessionsBox);
  }

  Box<HiveChatSession> get _box => Hive.box<HiveChatSession>(chatSessionsBox);

  @override
  Future<List<HiveChatSession>> getAllSessions() async {
    return _box.values.toList();
  }

  @override
  Future<HiveChatSession?> getSession(String sessionId) async {
    return _box.get(sessionId);
  }

  @override
  Future<void> saveSession(HiveChatSession session) async {
    await _box.put(session.id, session);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _box.delete(sessionId);
  }

  @override
  Future<void> updateSession(HiveChatSession session) async {
    await _box.put(session.id, session);
  }

  @override
  Future<void> close() async {
    await _box.close();
  }
}
