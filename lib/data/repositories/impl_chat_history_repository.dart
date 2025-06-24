import 'dart:async';
import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_chat_session.dart';

/// Concrete implementation of [ChatHistoryRepository]
///
/// Manages chat session persistence using [HiveStorageLocalDataSource]
/// Provides real-time data synchronization between BLoCs through streaming
///
/// Features:
/// - CRUD operations for chat sessions
/// - Real-time updates via broadcast streams
/// - Automatic data synchronization across multiple BLoCs
/// - Domain entity conversion from data models
class ImplChatHistoryRepository implements ChatHistoryRepository {

  /// Constructor for chat history repository implementation
  ///
  /// [_hiveStorageLocalDataSource] The local data source for chat session persistence
  ImplChatHistoryRepository(this._hiveStorageLocalDataSource);
  final HiveStorageLocalDataSource _hiveStorageLocalDataSource;

  // This enables real-time data synchronization between BLoCs
  // When data changes, all listening BLoCs will be notified automatically
  final StreamController<List<ChatSessionEntity>> _sessionsController = 
      StreamController<List<ChatSessionEntity>>.broadcast();

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
    await _notifyDataChanged();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _hiveStorageLocalDataSource.deleteSession(sessionId);
    
    // After deleting a session, emit updated data to all listening BLoCs
    // This ensures HomeBloc removes deleted sessions immediately
    await _notifyDataChanged();
  }

  @override
  Future<void> updateSession(ChatSessionEntity session) async {
    final hiveSession = HiveChatSession.fromDomain(session);
    await _hiveStorageLocalDataSource.updateSession(hiveSession);
    
    // After updating a session, emit updated data to all listening BLoCs
    // This ensures all BLoCs show the latest session information
    await _notifyDataChanged();
  }

  @override
  Stream<List<ChatSessionEntity>> watchAllSessions() {
    // BLoCs can listen to this stream to get real-time data updates
    return _sessionsController.stream;
  }

  /// Notify all stream listeners about data changes
  ///
  /// Fetches fresh data and broadcasts to all listening BLoCs
  /// Called after any data modification operation (save, update, delete)
  /// Ensures data consistency across the application
  Future<void> _notifyDataChanged() async {
    try {
      final sessions = await getAllSessions();
      _sessionsController.add(sessions);
    } catch (e) {
      _sessionsController.addError(e);
    }
  }

  /// Clean up resources and close stream controller
  ///
  /// Prevents memory leaks by properly disposing of the StreamController
  /// Should be called when the repository is no longer needed
  Future<void> dispose() async {
    await _sessionsController.close();
  }
} 
