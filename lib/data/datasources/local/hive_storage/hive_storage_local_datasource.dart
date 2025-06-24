import 'package:ai_chat_bot/data/models/hive_storage/hive_chat_session.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_memory_item.dart';

/// Abstract data source for Hive Storage local operations
///
/// Provides local storage functionality using [Hive](https://pub.dev/packages/hive_ce) NoSQL database
///
/// Manages two main data types:
/// - [HiveChatSession] for chat session persistence
/// - [HiveMemoryItem] for long-term memory storage
abstract class HiveStorageLocalDataSource {
  /// Get all chat sessions from local storage
  ///
  /// Returns a list of all [HiveChatSession] objects stored locally
  Future<List<HiveChatSession>> getAllSessions();

  /// Get a specific chat session by its ID
  ///
  /// [sessionId] The unique identifier of the session to retrieve
  /// Returns [HiveChatSession] if found, null otherwise
  Future<HiveChatSession?> getSession(String sessionId);

  /// Save a new chat session to local storage
  ///
  /// [session] The [HiveChatSession] object to save
  Future<void> saveSession(HiveChatSession session);

  /// Delete a chat session from local storage
  ///
  /// [sessionId] The unique identifier of the session to delete
  Future<void> deleteSession(String sessionId);

  /// Update an existing chat session in local storage
  ///
  /// [session] The updated [HiveChatSession] object
  Future<void> updateSession(HiveChatSession session);

  /// Get all memory items from local storage
  ///
  /// Returns a list of all [HiveMemoryItem] objects stored locally
  Future<List<HiveMemoryItem>> getAllMemoryItems();

  /// Get a specific memory item by its ID
  ///
  /// [id] The unique identifier of the memory item to retrieve
  /// Returns [HiveMemoryItem] if found, null otherwise
  Future<HiveMemoryItem?> getMemoryItem(String id);

  /// Save a new memory item to local storage
  ///
  /// [item] The [HiveMemoryItem] object to save
  Future<void> saveMemoryItem(HiveMemoryItem item);

  /// Update an existing memory item in local storage
  ///
  /// [item] The updated [HiveMemoryItem] object
  Future<void> updateMemoryItem(HiveMemoryItem item);

  /// Delete a memory item from local storage
  ///
  /// [id] The unique identifier of the memory item to delete
  Future<void> deleteMemoryItem(String id);

  /// Close the Hive storage and clean up resources
  ///
  /// Should be called when the data source is no longer needed
  Future<void> close();
}
