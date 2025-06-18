import 'dart:async';
import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_memory_items_usecase.dart';
import '../../../domain/usecases/save_memory_item_usecase.dart';
import '../../../domain/usecases/delete_memory_item_usecase.dart';
import '../../../domain/usecases/search_memory_items_usecase.dart';
import '../../../domain/repositories/memory/memory_repository.dart';

part 'memory_event.dart';
part 'memory_state.dart';

class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  final GetMemoryItemsUseCase _getMemoryItemsUseCase;
  final SaveMemoryItemUseCase _saveMemoryItemUseCase;
  final DeleteMemoryItemUseCase _deleteMemoryItemUseCase;
  final SearchMemoryItemsUseCase _searchMemoryItemsUseCase;
  final MemoryRepository _memoryRepository;
  late final StreamSubscription _dataSubscription;

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
    }, onError: (error) {});
  }

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
          error: null,
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