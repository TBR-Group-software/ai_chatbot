part of 'memory_bloc.dart';

abstract class MemoryEvent {}

class LoadMemoryEvent extends MemoryEvent {}

class AddMemoryEvent extends MemoryEvent {
  final MemoryItemEntity item;

  AddMemoryEvent(this.item);
}

class UpdateMemoryEvent extends MemoryEvent {
  final MemoryItemEntity item;

  UpdateMemoryEvent(this.item);
}

class DeleteMemoryEvent extends MemoryEvent {
  final String itemId;

  DeleteMemoryEvent(this.itemId);
}

class SearchMemoryEvent extends MemoryEvent {
  final String query;

  SearchMemoryEvent(this.query);
}

class DataUpdatedEvent extends MemoryEvent {
  final List<MemoryItemEntity> items;

  DataUpdatedEvent(this.items);
} 