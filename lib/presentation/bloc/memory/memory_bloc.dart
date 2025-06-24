import 'dart:async';
import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/domain/usecases/get_memory_items_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/save_memory_item_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/delete_memory_item_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/search_memory_items_usecase.dart';
import 'package:ai_chat_bot/domain/repositories/memory/memory_repository.dart';

part 'memory_event.dart';
part 'memory_state.dart';

/// BLoC for managing memory items and search functionality
///
/// Handles all memory-related operations including CRUD operations,
/// search functionality, and real-time data synchronization
///
/// Features:
/// - Load and display all memory items
/// - Add, update, and delete memory items
/// - Search through memory items with filtering
/// - Real-time updates via repository streams
/// - Maintain separate filtered list for search results
///
/// Uses multiple use cases for different operations:
/// - [GetMemoryItemsUseCase] for retrieval
/// - [SaveMemoryItemUseCase] for persistence
/// - [DeleteMemoryItemUseCase] for deletion
/// - [SearchMemoryItemsUseCase] for search operations
/// - [MemoryRepository] for real-time updates
class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {

  /// Constructor for memory BLoC
  ///
  /// [_getMemoryItemsUseCase] Use case for retrieving memory items
  /// [_saveMemoryItemUseCase] Use case for saving memory items
  /// [_deleteMemoryItemUseCase] Use case for deleting memory items
  /// [_searchMemoryItemsUseCase] Use case for searching memory items
  /// [_memoryRepository] Repository for real-time memory updates
  MemoryBloc(
    this._getMemoryItemsUseCase,
    this._saveMemoryItemUseCase,
    this._deleteMemoryItemUseCase,
    this._searchMemoryItemsUseCase,
    this._memoryRepository,
  ) : super(MemoryState.initial()) {
    on<LoadMemoryEvent>(_onLoadMemory);
    on<AddMemoryEvent>(_onAddMemory);
    on<UpdateMemoryEvent>(_onUpdateMemory);
    on<DeleteMemoryEvent>(_onDeleteMemory);
    on<SearchMemoryEvent>(_onSearchMemory);
    on<DataUpdatedEvent>(_onDataUpdated);

    _dataSubscription = _memoryRepository.watchAllMemoryItems().listen((
      items,
    ) {
      add(DataUpdatedEvent(items));
    }, onError: (error) {},);
  }
  final GetMemoryItemsUseCase _getMemoryItemsUseCase;
  final SaveMemoryItemUseCase _saveMemoryItemUseCase;
  final DeleteMemoryItemUseCase _deleteMemoryItemUseCase;
  final SearchMemoryItemsUseCase _searchMemoryItemsUseCase;
  final MemoryRepository _memoryRepository;
  late final StreamSubscription<List<MemoryItemEntity>> _dataSubscription;

  /// Handle load memory event
  ///
  /// Loads all memory items from storage and updates the state
  /// [event] The load memory event
  /// [emit] State emitter for updating UI state
  Future<void> _onLoadMemory(
    LoadMemoryEvent event,
    Emitter<MemoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final items = await _getMemoryItemsUseCase.call();

      emit(
        state.copyWith(
          isLoading: false,
          items: items,
          filteredItems: items,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  /// Handle add memory event
  ///
  /// Adds a new memory item to storage via use case
  /// Real-time updates are handled by repository stream
  /// [event] The add memory event containing the item to add
  /// [emit] State emitter for updating UI state
  Future<void> _onAddMemory(
    AddMemoryEvent event,
    Emitter<MemoryState> emit,
  ) async {
    try {
      await _saveMemoryItemUseCase.call(event.item);

      // The data will be updated through the stream subscription
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  /// Handle update memory event
  ///
  /// Updates an existing memory item in storage via use case
  /// Real-time updates are handled by repository stream
  /// [event] The update memory event containing the updated item
  /// [emit] State emitter for updating UI state
  Future<void> _onUpdateMemory(
    UpdateMemoryEvent event,
    Emitter<MemoryState> emit,
  ) async {
    try {
      await _saveMemoryItemUseCase.call(event.item);

      // The data will be updated through the stream subscription
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  /// Handle delete memory event
  ///
  /// Deletes a memory item from storage and updates local state immediately
  /// [event] The delete memory event containing the item ID to delete
  /// [emit] State emitter for updating UI state
  Future<void> _onDeleteMemory(
    DeleteMemoryEvent event,
    Emitter<MemoryState> emit,
  ) async {
    try {
      await _deleteMemoryItemUseCase.call(event.itemId);

      // Remove item from current state
      final updatedItems =
          state.items.where((item) => item.id != event.itemId).toList();
      final updatedFilteredItems =
          state.filteredItems.where((item) => item.id != event.itemId).toList();

      emit(
        state.copyWith(
          items: updatedItems,
          filteredItems: updatedFilteredItems,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString()));
    }
  }

  /// Handle search memory event
  ///
  /// Performs search across memory items and updates filtered results
  /// If query is empty, shows all items
  /// [event] The search memory event containing the search query
  /// [emit] State emitter for updating UI state
  Future<void> _onSearchMemory(
    SearchMemoryEvent event,
    Emitter<MemoryState> emit,
  ) async {
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(state.copyWith(filteredItems: state.items, searchQuery: ''));
    } else {
      try {
        final filteredItems = await _searchMemoryItemsUseCase.call(event.query);

        emit(
          state.copyWith(filteredItems: filteredItems, searchQuery: query),
        );
      } catch (error) {
        emit(state.copyWith(error: error.toString()));
      }
    }
  }

  /// Handle data updated event from repository stream
  ///
  /// Processes real-time updates from the memory repository
  /// Maintains current search filter if one is active
  /// [event] The data updated event containing new memory items
  /// [emit] State emitter for updating UI state
  void _onDataUpdated(DataUpdatedEvent event, Emitter<MemoryState> emit) {
    try {
      final items = event.items;

      List<MemoryItemEntity> filteredItems;
      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
        filteredItems = items.where((item) {
          return item.title.toLowerCase().contains(query) ||
              item.content.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query));
        }).toList();
      } else {
        filteredItems = items;
      }

      emit(
        state.copyWith(
          items: items,
          filteredItems: filteredItems,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _dataSubscription.cancel();
    return super.close();
  }
} 
