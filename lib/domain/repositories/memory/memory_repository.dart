import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';

/// Abstract repository for memory operations
/// Defines the contract for memory data operations
abstract class MemoryRepository {
  /// Get all memory items
  Future<List<MemoryItemEntity>> getAllMemoryItems();

  /// Get a specific memory item by ID
  Future<MemoryItemEntity?> getMemoryItem(String id);

  /// Save a new memory item
  Future<void> saveMemoryItem(MemoryItemEntity item);

  /// Update an existing memory item
  Future<void> updateMemoryItem(MemoryItemEntity item);

  /// Delete a memory item by ID
  Future<void> deleteMemoryItem(String id);

  /// Watch all memory items for real-time updates
  Stream<List<MemoryItemEntity>> watchAllMemoryItems();

  /// Search memory items by query
  Future<List<MemoryItemEntity>> searchMemoryItems(String query);

  /// Get relevant memory items for RAG context
  Future<List<MemoryItemEntity>> getRelevantMemoryItems(String query, {int limit = 5});
} 
