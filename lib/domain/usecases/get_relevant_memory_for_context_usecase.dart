import '../entities/memory_item_entity.dart';
import '../repositories/memory/memory_repository.dart';

class GetRelevantMemoryForContextUseCase {
  final MemoryRepository _memoryRepository;

  GetRelevantMemoryForContextUseCase(this._memoryRepository);

  Future<List<MemoryItemEntity>> call(String query, {int limit = 5}) {
    return _memoryRepository.getRelevantMemoryItems(query, limit: limit);
  }
} 