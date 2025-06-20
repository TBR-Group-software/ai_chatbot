import '../entities/memory_item_entity.dart';
import '../repositories/memory/memory_repository.dart';

/// Use case for retrieving all memory items from storage
///
/// Fetches all stored memory items sorted by most recent updates
/// Used to display the complete memory collection to users
///
/// Uses [MemoryRepository] for memory retrieval operations
class GetMemoryItemsUseCase {
  final MemoryRepository _memoryRepository;

  /// Constructor for get memory items use case
  ///
  /// [_memoryRepository] The memory repository for retrieval operations
  GetMemoryItemsUseCase(this._memoryRepository);

  /// Execute the use case to get all memory items
  ///
  /// Retrieves all memory items from storage, sorted by update date
  /// Returns a list of all [MemoryItemEntity] objects in the system
  Future<List<MemoryItemEntity>> call() {
    return _memoryRepository.getAllMemoryItems();
  }
} 