import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_history_repository.dart';
import '../services/hive_storage_service.dart';
import '../models/hive_chat_session.dart';

class ImplChatHistoryRepository implements ChatHistoryRepository {
  final HiveStorageService _storageService;

  ImplChatHistoryRepository(this._storageService);

  @override
  Future<List<ChatSession>> getAllSessions() async {
    final hiveSessions = await _storageService.getAllSessions();
    return hiveSessions.map((hiveSession) => hiveSession.toDomain()).toList();
  }

  @override
  Future<ChatSession?> getSession(String sessionId) async {
    final hiveSession = await _storageService.getSession(sessionId);
    return hiveSession?.toDomain();
  }

  @override
  Future<void> saveSession(ChatSession session) async {
    final hiveSession = HiveChatSession.fromDomain(session);
    await _storageService.saveSession(hiveSession);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _storageService.deleteSession(sessionId);
  }

  @override
  Future<void> updateSession(ChatSession session) async {
    final hiveSession = HiveChatSession.fromDomain(session);
    await _storageService.updateSession(hiveSession);
  }
} 