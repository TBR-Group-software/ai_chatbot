import '../entities/memory_item_entity.dart';
import '../repositories/memory/memory_repository.dart';

class SaveMemoryItemUseCase {
  final MemoryRepository _memoryRepository;

  SaveMemoryItemUseCase(this._memoryRepository);

  Future<void> call(MemoryItemEntity item) {
    return _memoryRepository.saveMemoryItem(item);
  }
} 