import 'package:ai_chat_bot/core/adapters/hive_registrar.g.dart';
import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_chat_session.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_memory_item.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Concrete implementation of [HiveStorageLocalDataSource]
///
/// Uses [Hive](https://pub.dev/packages/hive_ce) NoSQL database for local storage
/// and [path_provider](https://pub.dev/packages/path_provider) for application directory access
///
/// Manages two Hive boxes:
/// - `chat_sessions` for [HiveChatSession] objects
/// - `memory_items` for [HiveMemoryItem] objects
class ImplHiveStorageLocalDataSource implements HiveStorageLocalDataSource {
  static const String chatSessionsBox = 'chat_sessions';
  static const String memoryBox = 'memory_items';

  /// Initialize Hive database and open required boxes
  ///
  /// Sets up Hive with application documents directory path
  /// Registers type adapters and opens both chat sessions and memory boxes
  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive
      ..init(appDocumentDir.path)
      ..registerAdapters();
    await Hive.openBox<HiveChatSession>(chatSessionsBox);
    await Hive.openBox<HiveMemoryItem>(memoryBox);
  }

  /// Get reference to the chat sessions box
  ///
  /// Returns the Hive box containing [HiveChatSession] objects
  Box<HiveChatSession> get _chatBox =>
      Hive.box<HiveChatSession>(chatSessionsBox);
      
  /// Get reference to the memory items box
  ///
  /// Returns the Hive box containing [HiveMemoryItem] objects
  Box<HiveMemoryItem> get _memoryBox => Hive.box<HiveMemoryItem>(memoryBox);

  @override
  Future<List<HiveChatSession>> getAllSessions() async {
    return _chatBox.values.toList();
  }

  @override
  Future<HiveChatSession?> getSession(String sessionId) async {
    return _chatBox.get(sessionId);
  }

  @override
  Future<void> saveSession(HiveChatSession session) async {
    await _chatBox.put(session.id, session);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _chatBox.delete(sessionId);
  }

  @override
  Future<void> updateSession(HiveChatSession session) async {
    await _chatBox.put(session.id, session);
  }

  @override
  Future<List<HiveMemoryItem>> getAllMemoryItems() async {
    return _memoryBox.values.toList();
  }

  @override
  Future<HiveMemoryItem?> getMemoryItem(String id) async {
    return _memoryBox.get(id);
  }

  @override
  Future<void> saveMemoryItem(HiveMemoryItem item) async {
    await _memoryBox.put(item.id, item);
  }

  @override
  Future<void> updateMemoryItem(HiveMemoryItem item) async {
    await _memoryBox.put(item.id, item);
  }

  @override
  Future<void> deleteMemoryItem(String id) async {
    await _memoryBox.delete(id);
  }

  @override
  Future<void> close() async {
    await _chatBox.close();
    await _memoryBox.close();
  }
}
