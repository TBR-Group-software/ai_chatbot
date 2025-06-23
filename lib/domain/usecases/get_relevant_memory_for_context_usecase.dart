import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:ai_chat_bot/domain/repositories/memory/memory_repository.dart';

/// Use case for retrieving contextually relevant memory items
///
/// Finds memory items most relevant to a given query using intelligent
/// matching algorithms. Used to enhance AI responses with relevant context
///
/// Uses [MemoryRepository] for intelligent memory retrieval operations
class GetRelevantMemoryForContextUseCase {

  /// Constructor for get relevant memory use case
  ///
  /// [_memoryRepository] The memory repository for contextual retrieval operations
  GetRelevantMemoryForContextUseCase(this._memoryRepository);
  final MemoryRepository _memoryRepository;

  /// Execute the use case to get relevant memory items
  ///
  /// Finds memory items most relevant to the provided query using
  /// similarity algorithms and relevance scoring
  /// [query] The context query to find relevant memories for
  /// Returns a list of the most relevant [MemoryItemEntity] objects
  Future<List<MemoryItemEntity>> call(String query, {int limit = 5}) {
    return _memoryRepository.getRelevantMemoryItems(query, limit: limit);
  }
} 
