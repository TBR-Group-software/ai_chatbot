import 'package:hive_ce/hive.dart';
import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';

part 'hive_memory_item.g.dart';

@HiveType(typeId: 2)
class HiveMemoryItem extends HiveObject {

  HiveMemoryItem({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HiveMemoryItem.fromDomain(MemoryItemEntity memory) {
    return HiveMemoryItem(
      id: memory.id,
      title: memory.title,
      content: memory.content,
      tags: memory.tags,
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
    );
  }
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  MemoryItemEntity toDomain() {
    return MemoryItemEntity(
      id: id,
      title: title,
      content: content,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
} 
