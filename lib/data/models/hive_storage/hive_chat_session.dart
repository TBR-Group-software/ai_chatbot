import 'package:hive_ce/hive.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_chat_message.dart';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';

part 'hive_chat_session.g.dart';

@HiveType(typeId: 0)
class HiveChatSession extends HiveObject {

  HiveChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  // Convert from domain entity
  factory HiveChatSession.fromDomain(ChatSessionEntity session) {
    return HiveChatSession(
      id: session.id,
      title: session.title,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      messages: session.messages
          .map(HiveChatMessage.fromDomain)
          .toList(),
    );
  }
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  List<HiveChatMessage> messages;

  // Convert to domain entity
  ChatSessionEntity toDomain() {
    return ChatSessionEntity(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      messages: messages.map((msg) => msg.toDomain()).toList(),
    );
  }
} 
