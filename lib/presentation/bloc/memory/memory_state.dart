part of 'memory_bloc.dart';

/// State class for the memory BLoC
///
/// Contains the current state of memory management including
/// all memory items, filtered results, loading status, and search query
///
/// Used to manage UI state for memory item display and search functionality
class MemoryState {

  /// Constructor for memory state
  ///
  /// [isLoading] Whether the app is currently loading data
  /// [error] Error message if any operation failed
  /// [items] Complete list of all memory items
  /// [filteredItems] Filtered list based on search query
  /// [searchQuery] Current search query string
  MemoryState({
    required this.isLoading,
    this.error,
    required this.items,
    required this.filteredItems,
    this.searchQuery = '',
  });

  /// Factory constructor for initial memory state
  ///
  /// Creates the initial state with empty lists and no loading
  /// Returns a [MemoryState] with default values
  factory MemoryState.initial() => MemoryState(
    isLoading: false,
    items: [],
    filteredItems: [],
  );
  final bool isLoading;
  final String? error;
  final List<MemoryItemEntity> items;
  final List<MemoryItemEntity> filteredItems;
  final String searchQuery;

  /// Create a copy of the current state with optional modifications
  ///
  /// Allows updating specific properties while keeping others unchanged
  /// [isLoading] New loading status (optional)
  /// [error] New error message (optional)
  /// [items] New list of all memory items (optional)
  /// [filteredItems] New list of filtered memory items (optional)
  /// [searchQuery] New search query string (optional)
  /// Returns a new [MemoryState] instance with updated values
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
