/// Domain entity for memory items
/// Represents a piece of knowledge stored in the memory system
class MemoryItemEntity { // For RAG ranking

  const MemoryItemEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.relevanceScore,
  });
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? relevanceScore;

  MemoryItemEntity copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
  }) {
    return MemoryItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }

  @override
  String toString() {
    return 'MemoryItemEntity(id: $id, title: $title, content: $content, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, relevanceScore: $relevanceScore)';
  }
}
