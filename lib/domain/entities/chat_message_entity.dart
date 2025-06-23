class ChatMessageEntity {

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.sessionId,
  });
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String sessionId;

  ChatMessageEntity copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? sessionId,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
    );
  }
} 
