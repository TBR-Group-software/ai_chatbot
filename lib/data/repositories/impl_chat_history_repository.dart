import 'dart:async';
import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/chat_history/chat_history_repository.dart';
import '../models/hive_storage/hive_chat_session.dart';

class ImplChatHistoryRepository implements ChatHistoryRepository {
  final HiveStorageLocalDataSource _hiveStorageLocalDataSource;

  // This enables real-time data synchronization between BLoCs
  // When data changes, all listening BLoCs will be notified automatically
  final StreamController<List<ChatSessionEntity>> _sessionsController = 
      StreamController<List<ChatSessionEntity>>.broadcast();

  ImplChatHistoryRepository(this._hiveStorageLocalDataSource);

  @override
  Future<List<ChatSessionEntity>> getAllSessions() async {
    final hiveSessions = await _hiveStorageLocalDataSource.getAllSessions();
    return hiveSessions.map((hiveSession) => hiveSession.toDomain()).toList();
  }

  @override
  Future<ChatSessionEntity?> getSession(String sessionId) async {
    final hiveSession = await _hiveStorageLocalDataSource.getSession(sessionId);
    return hiveSession?.toDomain();
  }

  @override
  Future<void> saveSession(ChatSessionEntity session) async {
    final hiveSession = HiveChatSession.fromDomain(session);
    await _hiveStorageLocalDataSource.saveSession(hiveSession);
    
    // After saving a session, emit updated data to all listening BLoCs
    // This ensures HomeBloc shows new sessions immediately after creation
    _notifyDataChanged();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _hiveStorageLocalDataSource.deleteSession(sessionId);
    
    // After deleting a session, emit updated data to all listening BLoCs
    // This ensures HomeBloc removes deleted sessions immediately
    _notifyDataChanged();
  }

  @override
  Future<void> updateSession(ChatSessionEntity session) async {
    final hiveSession = HiveChatSession.fromDomain(session);
    await _hiveStorageLocalDataSource.updateSession(hiveSession);
    
    // After updating a session, emit updated data to all listening BLoCs
    // This ensures all BLoCs show the latest session information
    _notifyDataChanged();
  }

  @override
  Stream<List<ChatSessionEntity>> watchAllSessions() {
    // BLoCs can listen to this stream to get real-time data updates
    return _sessionsController.stream;
  }

  // This method fetches fresh data and emits it to all listeners
  // It's called after any data modification operation
  Future<void> _notifyDataChanged() async {
    try {
      final sessions = await getAllSessions();
      _sessionsController.add(sessions);
    } catch (e) {
      _sessionsController.addError(e);
    }
  }

  // This prevents memory leaks by closing the StreamController
  // Should be called when the repository is no longer needed
  void dispose() {
    _sessionsController.close();
  }
} 