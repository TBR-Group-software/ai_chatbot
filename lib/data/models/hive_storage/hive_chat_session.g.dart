// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_chat_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveChatSessionAdapter extends TypeAdapter<HiveChatSession> {
  @override
  final typeId = 0;

  @override
  HiveChatSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveChatSession(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      messages: (fields[4] as List).cast<HiveChatMessage>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveChatSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.messages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveChatSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
