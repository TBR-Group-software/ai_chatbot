// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveChatMessageAdapter extends TypeAdapter<HiveChatMessage> {
  @override
  final typeId = 1;

  @override
  HiveChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveChatMessage(
      id: fields[0] as String,
      content: fields[1] as String,
      isUser: fields[2] as bool,
      timestamp: fields[3] as DateTime,
      sessionId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveChatMessage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.isUser)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.sessionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
