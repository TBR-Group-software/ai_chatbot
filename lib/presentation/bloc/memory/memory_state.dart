part of 'memory_bloc.dart';

class MemoryState {
  final bool isLoading;
  final String? error;
  final List<MemoryItemEntity> items;
  final List<MemoryItemEntity> filteredItems;
  final String searchQuery;

  MemoryState({
    required this.isLoading,
    this.error,
    required this.items,
    required this.filteredItems,
    this.searchQuery = '',
  });

  factory MemoryState.initial() => MemoryState(
    isLoading: false,
    items: [],
    filteredItems: [],
  );

  MemoryState copyWith({
    bool? isLoading,
    String? error,
    List<MemoryItemEntity>? items,
    List<MemoryItemEntity>? filteredItems,
    String? searchQuery,
  }) {
    return MemoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
} 