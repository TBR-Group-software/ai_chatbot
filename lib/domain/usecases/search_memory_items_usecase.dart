import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:ai_chat_bot/domain/repositories/memory/memory_repository.dart';

/// Use case for searching memory items by query
///
/// Performs text-based search across memory items including titles,
/// content, and tags. Supports partial matching and filtering
///
/// Uses [MemoryRepository] for memory search operations
class SearchMemoryItemsUseCase {

  /// Constructor for search memory items use case
  ///
  /// [_memoryRepository] The memory repository for search operations
  SearchMemoryItemsUseCase(this._memoryRepository);
  final MemoryRepository _memoryRepository;

  /// Execute the use case to search memory items
  ///
  /// Searches through all memory items for matches with the provided query
  /// [query] The search query to match against titles, content, and tags
  /// Returns a list of [MemoryItemEntity] objects matching the search criteria
  Future<List<MemoryItemEntity>> call(String query) {
    return _memoryRepository.searchMemoryItems(query);
  }
} 
