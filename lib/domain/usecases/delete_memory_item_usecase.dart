import '../repositories/memory/memory_repository.dart';

class DeleteMemoryItemUseCase {
  final MemoryRepository _memoryRepository;

  DeleteMemoryItemUseCase(this._memoryRepository);

  Future<void> call(String id) {
    return _memoryRepository.deleteMemoryItem(id);
  }
} 