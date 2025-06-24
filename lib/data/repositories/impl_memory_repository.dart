import 'dart:async';
import 'dart:math';

import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_memory_item.dart';
import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:ai_chat_bot/domain/repositories/memory/memory_repository.dart';

/// Concrete implementation of [MemoryRepository]
///
/// Manages long-term memory storage using [HiveStorageLocalDataSource]
/// Provides intelligent memory retrieval with relevance scoring algorithms
///
/// Features:
/// - CRUD operations for memory items
/// - Real-time memory updates via streams
/// - Semantic search with relevance scoring
/// - Jaccard similarity algorithms for content matching
/// - Recency-based scoring boosts
class ImplMemoryRepository implements MemoryRepository {

  /// Constructor for memory repository implementation
  ///
  /// [_hiveStorageLocalDataSource] The local data source for memory persistence
  ImplMemoryRepository(this._hiveStorageLocalDataSource);
  final HiveStorageLocalDataSource _hiveStorageLocalDataSource;
  final StreamController<List<MemoryItemEntity>> _memoryStreamController = StreamController<List<MemoryItemEntity>>.broadcast();

  @override
  Future<List<MemoryItemEntity>> getAllMemoryItems() async {
    final hiveMemoryItems = await _hiveStorageLocalDataSource.getAllMemoryItems();
    final memoryItems = hiveMemoryItems.map((hiveItem) => hiveItem.toDomain()).toList();
    
    // Sort by updated date (most recent first)
    memoryItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return memoryItems;
  }

  @override
  Future<MemoryItemEntity?> getMemoryItem(String id) async {
    final hiveMemoryItem = await _hiveStorageLocalDataSource.getMemoryItem(id);
    return hiveMemoryItem?.toDomain();
  }

  @override
  Future<void> saveMemoryItem(MemoryItemEntity item) async {
    final hiveMemoryItem = HiveMemoryItem.fromDomain(item);
    await _hiveStorageLocalDataSource.saveMemoryItem(hiveMemoryItem);
    _notifyMemoryUpdated();
  }

  @override
  Future<void> updateMemoryItem(MemoryItemEntity item) async {
    final hiveMemoryItem = HiveMemoryItem.fromDomain(item);
    await _hiveStorageLocalDataSource.updateMemoryItem(hiveMemoryItem);
    _notifyMemoryUpdated();
  }

  @override
  Future<void> deleteMemoryItem(String id) async {
    await _hiveStorageLocalDataSource.deleteMemoryItem(id);
    _notifyMemoryUpdated();
  }

  @override
  Stream<List<MemoryItemEntity>> watchAllMemoryItems() {
    return _memoryStreamController.stream;
  }

  @override
  Future<List<MemoryItemEntity>> searchMemoryItems(String query) async {
    final allItems = await getAllMemoryItems();
    
    if (query.isEmpty) {
      return allItems;
    }

    final queryLower = query.toLowerCase();
    return allItems.where((item) {
      return item.title.toLowerCase().contains(queryLower) ||
          item.content.toLowerCase().contains(queryLower) ||
          item.tags.any((tag) => tag.toLowerCase().contains(queryLower));
    }).toList();
  }

  @override
  Future<List<MemoryItemEntity>> getRelevantMemoryItems(String query, {int limit = 5}) async {
    final allItems = await getAllMemoryItems();
    
    if (allItems.isEmpty || query.isEmpty) {
      return [];
    }

    // Calculate relevance scores using simple text similarity
    final scoredItems = <MemoryItemEntity>[];
    
    for (final item in allItems) {
      final score = _calculateRelevanceScore(query, item);
      if (score > 0.1) { // Only include items with meaningful relevance
        scoredItems.add(item.copyWith(relevanceScore: score));
      }
    }

    // Sort by relevance score (highest first)
    scoredItems.sort((a, b) => (b.relevanceScore ?? 0).compareTo(a.relevanceScore ?? 0));

    // Return top results up to limit
    return scoredItems.take(limit).toList();
  }

  /// Calculate relevance score using text similarity algorithms
  ///
  /// [query] The search query to match against
  /// [item] The memory item to score for relevance
  /// 
  /// Uses Jaccard similarity for text matching combined with:
  /// - Title scoring (weighted 2x)
  /// - Content scoring
  /// - Tag scoring (weighted 1.5x)
  /// - Recency bonus for recent items
  /// 
  /// Returns a score between 0.0 and 1.0
  double _calculateRelevanceScore(String query, MemoryItemEntity item) {
    final queryWords = _extractWords(query.toLowerCase());
    final titleWords = _extractWords(item.title.toLowerCase());
    final contentWords = _extractWords(item.content.toLowerCase());
    final tagWords = item.tags.map((tag) => tag.toLowerCase()).toList();

    // Calculate different similarity scores
    final titleScore = _calculateJaccardSimilarity(queryWords, titleWords) * 2.0; // Title is more important
    final contentScore = _calculateJaccardSimilarity(queryWords, contentWords);
    final tagScore = _calculateTagSimilarity(queryWords, tagWords) * 1.5; // Tags are important

    // Combine scores with weights
    final combinedScore = (titleScore + contentScore + tagScore) / 4.5;

    // Add recency bonus (more recent items get slight boost)
    final daysSinceUpdate = DateTime.now().difference(item.updatedAt).inDays;
    final recencyBonus = max(0, (30 - daysSinceUpdate) / 30 * 0.1); // Up to 10% bonus for items updated within 30 days

    return min(1, combinedScore + recencyBonus);
  }

  /// Extract meaningful words from text, removing common stop words
  ///
  /// [text] The text to extract words from
  /// 
  /// Removes punctuation and common stop words
  /// 
  /// Only includes words longer than 2 characters
  /// 
  /// Returns list of processed words
  List<String> _extractWords(String text) {
    final stopWords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should'};
    
    return text
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .toList();
  }

  /// Calculate Jaccard similarity between two sets of words
  ///
  /// [set1] First set of words
  /// 
  /// [set2] Second set of words
  /// 
  /// Uses intersection over union formula: |A ∩ B| / |A ∪ B|
  /// Returns similarity score between 0.0 and 1.0
  double _calculateJaccardSimilarity(List<String> set1, List<String> set2) {
    if (set1.isEmpty && set2.isEmpty) {
      return 0;
    }
    
    final intersection = set1.toSet().intersection(set2.toSet()).length;
    final union = set1.toSet().union(set2.toSet()).length;
    
    return union > 0 ? intersection / union : 0.0;
  }

  /// Calculate tag similarity with exact and partial matching
  ///
  /// [queryWords] Words from the search query.
  /// [tags] List of tags to match against.
  /// 
  /// Exact tag matches get full score (1.0)
  /// 
  /// Partial matches get half score (0.5)
  /// 
  /// Returns normalized similarity score
  double _calculateTagSimilarity(List<String> queryWords, List<String> tags) {
    if (tags.isEmpty) {
      return 0;
    }
    
    double score = 0;
    for (final tag in tags) {
      for (final word in queryWords) {
        if (tag.contains(word) || word.contains(tag)) {
          score += tag == word ? 1.0 : 0.5; // Exact match vs partial match
        }
      }
    }
    
    return min(1, score / queryWords.length);
  }

  /// Notify listeners about memory updates
  ///
  /// Fetches updated memory items and broadcasts to all stream listeners
  /// Called after any CRUD operation to maintain data consistency
  void _notifyMemoryUpdated() async {
    final updatedItems = await getAllMemoryItems();
    _memoryStreamController.add(updatedItems);
  }

  /// Clean up resources and close stream controller
  ///
  /// Should be called when the repository is no longer needed
  /// to prevent memory leaks
  void dispose() {
    _memoryStreamController.close();
  }
}
