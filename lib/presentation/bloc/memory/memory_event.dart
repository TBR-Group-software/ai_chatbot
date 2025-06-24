part of 'memory_bloc.dart';

/// Base abstract class for all memory-related events
abstract class MemoryEvent {}

/// Event to trigger loading of all memory items
///
/// Initiates the loading process for all stored memory items
class LoadMemoryEvent extends MemoryEvent {}

/// Event to add a new memory item
///
/// Triggers the creation and storage of a new memory item
class AddMemoryEvent extends MemoryEvent {

  /// Constructor for add memory event
  ///
  /// [item] The memory item to add to storage
  AddMemoryEvent(this.item);
  final MemoryItemEntity item;
}

/// Event to update an existing memory item
///
/// Triggers the modification of an existing memory item in storage
class UpdateMemoryEvent extends MemoryEvent {

  /// Constructor for update memory event
  ///
  /// [item] The updated memory item to save
  UpdateMemoryEvent(this.item);
  final MemoryItemEntity item;
}

/// Event to delete a memory item
///
/// Triggers the removal of a memory item from storage
class DeleteMemoryEvent extends MemoryEvent {

  /// Constructor for delete memory event
  ///
  /// [itemId] The unique identifier of the memory item to delete
  DeleteMemoryEvent(this.itemId);
  final String itemId;
}

/// Event to search through memory items
///
/// Triggers filtering of memory items based on search query
class SearchMemoryEvent extends MemoryEvent {

  /// Constructor for search memory event
  ///
  /// [query] The search query to filter memory items
  SearchMemoryEvent(this.query);
  final String query;
}

/// Internal event for handling real-time data updates
///
/// Triggered automatically when the repository stream
/// emits new memory item data
class DataUpdatedEvent extends MemoryEvent {

  /// Constructor for data updated event
  ///
  /// [items] The updated list of memory items from repository
  DataUpdatedEvent(this.items);
  final List<MemoryItemEntity> items;
} 
