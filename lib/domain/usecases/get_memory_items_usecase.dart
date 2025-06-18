import '../entities/memory_item_entity.dart';
import '../repositories/memory/memory_repository.dart';

class GetMemoryItemsUseCase {
  final MemoryRepository _memoryRepository;

  GetMemoryItemsUseCase(this._memoryRepository);

  Future<List<MemoryItemEntity>> call() {
    return _memoryRepository.getAllMemoryItems();
  }
} 