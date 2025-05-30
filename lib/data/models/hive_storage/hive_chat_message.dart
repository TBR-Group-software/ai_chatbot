import 'package:hive_ce/hive.dart';
import '../../../domain/entities/chat_message_entity.dart';

part 'hive_chat_message.g.dart';

@HiveType(typeId: 1)
class HiveChatMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  bool isUser;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String sessionId;

  HiveChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.sessionId,
  });

  // Convert from domain entity
  factory HiveChatMessage.fromDomain(ChatMessageEntity message) {
    return HiveChatMessage(
      id: message.id,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
      sessionId: message.sessionId,
    );
  }

  // Convert to domain entity
  ChatMessageEntity toDomain() {
    return ChatMessageEntity(
      id: id,
      content: content,
      isUser: isUser,
      timestamp: timestamp,
      sessionId: sessionId,
    );
  }
} 