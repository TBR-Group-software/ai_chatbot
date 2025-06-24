import 'package:ai_chat_bot/domain/repositories/memory/memory_repository.dart';

/// Use case for deleting memory items from storage
///
/// Permanently removes memory items from long-term storage
/// 
/// Used to clean up outdated or unwanted memories
///
/// Uses [MemoryRepository] for memory deletion operations
class DeleteMemoryItemUseCase {

  /// Constructor for delete memory item use case
  ///
  /// [_memoryRepository] The memory repository for deletion operations
  DeleteMemoryItemUseCase(this._memoryRepository);
  final MemoryRepository _memoryRepository;

  /// Execute the use case to delete a memory item
  ///
  /// Permanently removes the memory item with the specified ID
  /// [id] The unique identifier of the memory item to delete
  /// Returns when the deletion operation is complete
  Future<void> call(String id) {
    return _memoryRepository.deleteMemoryItem(id);
  }
} 
