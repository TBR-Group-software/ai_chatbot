import '../entities/memory_item_entity.dart';
import '../repositories/memory/memory_repository.dart';

class SearchMemoryItemsUseCase {
  final MemoryRepository _memoryRepository;

  SearchMemoryItemsUseCase(this._memoryRepository);

  Future<List<MemoryItemEntity>> call(String query) {
    return _memoryRepository.searchMemoryItems(query);
  }
} 