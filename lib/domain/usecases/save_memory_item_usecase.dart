import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:ai_chat_bot/domain/repositories/memory/memory_repository.dart';

/// Use case for saving memory items to long-term storage
///
/// Persists new memory items for future retrieval and context enhancement
/// Used to build the AI's knowledge base from user interactions
///
/// Uses [MemoryRepository] for memory persistence operations
class SaveMemoryItemUseCase {

  /// Constructor for save memory item use case
  ///
  /// [_memoryRepository] The memory repository for persistence operations
  SaveMemoryItemUseCase(this._memoryRepository);
  final MemoryRepository _memoryRepository;

  /// Execute the use case to save a memory item
  ///
  /// Persists the provided memory item to long-term storage
  /// [item] The [MemoryItemEntity] to save to storage
  /// Returns when the save operation is complete
  Future<void> call(MemoryItemEntity item) {
    return _memoryRepository.saveMemoryItem(item);
  }
} 
