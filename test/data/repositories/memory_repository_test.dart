import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_memory_item.dart';
import 'package:ai_chat_bot/data/repositories/impl_memory_repository.dart';
import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

/// Mock classes using mocktail
class MockHiveStorageLocalDataSource extends Mock implements HiveStorageLocalDataSource {}

void main() {
  group('ImplMemoryRepository', () {
    late ImplMemoryRepository repository;
    late MockHiveStorageLocalDataSource mockHiveStorageLocalDataSource;
    
    late List<MemoryItemEntity> mockMemoryItems;
    late MemoryItemEntity mockMemoryItem;
    late List<HiveMemoryItem> mockHiveMemoryItems;

    /// Setup before each test
    setUp(() {
      mockHiveStorageLocalDataSource = MockHiveStorageLocalDataSource();
      repository = ImplMemoryRepository(mockHiveStorageLocalDataSource);
      
      mockMemoryItems = TestHelpers.generateMockMemoryItems();
      mockMemoryItem = TestHelpers.generateMockMemoryItem();
      
      // Create mock Hive memory items
      mockHiveMemoryItems = mockMemoryItems.map(HiveMemoryItem.fromDomain,
      ).toList();

      // Register fallback values for mocktail
      registerFallbackValue(mockHiveMemoryItems.first);
    });

    /// Cleanup after each test
    tearDown(() {
      repository.dispose();
    });

    group('getAllMemoryItems', () {
      test('should return sorted memory items from data source', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => mockHiveMemoryItems);

        // Act
        final result = await repository.getAllMemoryItems();

        // Assert
        expect(result.length, equals(mockMemoryItems.length));
        // Check that we get the expected items (the first item in mock data has ID '3', not '1')
        expect(result.any((item) => item.id == '1'), isTrue);
        expect(result.any((item) => item.id == '2'), isTrue);
        expect(result.any((item) => item.id == '3'), isTrue);
        // Verify items are sorted by updatedAt (most recent first)
        for (var i = 0; i < result.length - 1; i++) {
          expect(result[i].updatedAt.isAfter(result[i + 1].updatedAt) ||
                 result[i].updatedAt.isAtSameMomentAs(result[i + 1].updatedAt), 
                 isTrue,);
        }
        verify(() => mockHiveStorageLocalDataSource.getAllMemoryItems()).called(1);
      });

      test('should handle empty list from data source', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllMemoryItems();

        // Assert
        expect(result, isEmpty);
        verify(() => mockHiveStorageLocalDataSource.getAllMemoryItems()).called(1);
      });

      test('should handle error from data source', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenThrow(Exception('Data source error'));

        // Act & Assert
        expect(() => repository.getAllMemoryItems(), throwsException);
        verify(() => mockHiveStorageLocalDataSource.getAllMemoryItems()).called(1);
      });
    });

    group('getMemoryItem', () {
      const testId = 'test-id';

      test('should return memory item when found', () async {
        // Arrange
        final mockHiveItem = HiveMemoryItem.fromDomain(mockMemoryItem);
        when(() => mockHiveStorageLocalDataSource.getMemoryItem(testId))
            .thenAnswer((_) async => mockHiveItem);

        // Act
        final result = await repository.getMemoryItem(testId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(mockMemoryItem.id));
        expect(result.title, equals(mockMemoryItem.title));
        verify(() => mockHiveStorageLocalDataSource.getMemoryItem(testId)).called(1);
      });

      test('should return null when item not found', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getMemoryItem(testId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getMemoryItem(testId);

        // Assert
        expect(result, isNull);
        verify(() => mockHiveStorageLocalDataSource.getMemoryItem(testId)).called(1);
      });

      test('should handle error from data source', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getMemoryItem(testId))
            .thenThrow(Exception('Item not found'));

        // Act & Assert
        expect(() => repository.getMemoryItem(testId), throwsException);
        verify(() => mockHiveStorageLocalDataSource.getMemoryItem(testId)).called(1);
      });
    });

    group('saveMemoryItem', () {
      test('should save memory item and notify stream', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.saveMemoryItem(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => [HiveMemoryItem.fromDomain(mockMemoryItem)]);

        // Act
        await repository.saveMemoryItem(mockMemoryItem);

        // Assert
        verify(() => mockHiveStorageLocalDataSource.saveMemoryItem(any())).called(1);
        // Stream notification is tested separately due to async nature
      });

      test('should handle save error', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.saveMemoryItem(any()))
            .thenThrow(Exception('Save failed'));

        // Act & Assert
        expect(() => repository.saveMemoryItem(mockMemoryItem), throwsException);
        verify(() => mockHiveStorageLocalDataSource.saveMemoryItem(any())).called(1);
      });
    });

    group('updateMemoryItem', () {
      test('should update memory item and notify stream', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.updateMemoryItem(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => [HiveMemoryItem.fromDomain(mockMemoryItem)]);

        // Act
        await repository.updateMemoryItem(mockMemoryItem);

        // Assert
        verify(() => mockHiveStorageLocalDataSource.updateMemoryItem(any())).called(1);
      });

      test('should handle update error', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.updateMemoryItem(any()))
            .thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(() => repository.updateMemoryItem(mockMemoryItem), throwsException);
        verify(() => mockHiveStorageLocalDataSource.updateMemoryItem(any())).called(1);
      });
    });

    group('deleteMemoryItem', () {
      const testId = 'test-id';

      test('should delete memory item and notify stream', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.deleteMemoryItem(testId))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => []);

        // Act
        await repository.deleteMemoryItem(testId);

        // Assert
        verify(() => mockHiveStorageLocalDataSource.deleteMemoryItem(testId)).called(1);
      });

      test('should handle delete error', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.deleteMemoryItem(testId))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(() => repository.deleteMemoryItem(testId), throwsException);
        verify(() => mockHiveStorageLocalDataSource.deleteMemoryItem(testId)).called(1);
      });
    });

    group('watchAllMemoryItems', () {
      test('should provide stream of memory items', () {
        // Arrange & Act
        final stream = repository.watchAllMemoryItems();

        // Assert
        expect(stream, isA<Stream<List<MemoryItemEntity>>>());
      });
    });

    group('searchMemoryItems', () {
      test('should return filtered items based on query', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => mockHiveMemoryItems);

        // Act
        final result = await repository.searchMemoryItems('flutter');

        // Assert
        expect(result.length, lessThanOrEqualTo(mockMemoryItems.length));
        // Verify that returned items contain the search query
        for (final item in result) {
          final containsQuery = item.title.toLowerCase().contains('flutter') ||
              item.content.toLowerCase().contains('flutter') ||
              item.tags.any((tag) => tag.toLowerCase().contains('flutter'));
          expect(containsQuery, isTrue);
        }
      });

      test('should return all items when query is empty', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => mockHiveMemoryItems);

        // Act
        final result = await repository.searchMemoryItems('');

        // Assert
        expect(result.length, equals(mockMemoryItems.length));
      });

      test('should return empty list when no matches found', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => mockHiveMemoryItems);

        // Act
        final result = await repository.searchMemoryItems('nonexistentquery');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getRelevantMemoryItems', () {
      test('should return relevant items with scores', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => mockHiveMemoryItems);

        // Act
        final result = await repository.getRelevantMemoryItems('flutter bloc pattern');

        // Assert
        expect(result.length, lessThanOrEqualTo(5)); // Default limit
        // Items should have relevance scores
        for (final item in result) {
          expect(item.relevanceScore, isNotNull);
          expect(item.relevanceScore! > 0, isTrue);
        }
        // Items should be sorted by relevance score (highest first)
        for (var i = 0; i < result.length - 1; i++) {
          expect(result[i].relevanceScore! >= result[i + 1].relevanceScore!, isTrue);
        }
      });

      test('should respect limit parameter', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => mockHiveMemoryItems);

        // Act
        final result = await repository.getRelevantMemoryItems('flutter', limit: 2);

        // Assert
        expect(result.length, lessThanOrEqualTo(2));
      });

      test('should return empty list when query is empty', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => mockHiveMemoryItems);

        // Act
        final result = await repository.getRelevantMemoryItems('');

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when no items available', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getRelevantMemoryItems('flutter');

        // Assert
        expect(result, isEmpty);
      });

      test('should filter out items with low relevance scores', () async {
        // Arrange
        final itemsWithDifferentContent = [
          TestHelpers.generateMockMemoryItem(
            id: 'high-relevance',
            title: 'Flutter Bloc Pattern Tutorial',
            content: 'Complete guide to Flutter Bloc pattern implementation',
            tags: ['flutter', 'bloc'],
          ),
          TestHelpers.generateMockMemoryItem(
            id: 'low-relevance',
            title: 'Cooking Recipe',
            content: 'How to cook pasta',
            tags: ['cooking'],
          ),
        ];
        
        final hiveItems = itemsWithDifferentContent.map(HiveMemoryItem.fromDomain,
        ).toList();
        
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => hiveItems);

        // Act
        final result = await repository.getRelevantMemoryItems('flutter bloc');

        // Assert
        // Should only return items with meaningful relevance (> 0.1)
        expect(result.length, equals(1));
        expect(result.first.id, equals('high-relevance'));
      });
    });

    group('stream notifications', () {
      test('should emit updated data after save operation', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.saveMemoryItem(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => [HiveMemoryItem.fromDomain(mockMemoryItem)]);

        final stream = repository.watchAllMemoryItems();
        
        // Act
        await repository.saveMemoryItem(mockMemoryItem);

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<MemoryItemEntity>>((items) => 
            items.isNotEmpty && items.first.id == mockMemoryItem.id,
          ),),
        );
      });

      test('should emit updated data after delete operation', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.deleteMemoryItem(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => []);

        final stream = repository.watchAllMemoryItems();
        
        // Act
        await repository.deleteMemoryItem('test-id');

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<MemoryItemEntity>>((items) => items.isEmpty)),
        );
      });
    });

    group('relevance scoring', () {
      test('should prioritize title matches over content matches', () async {
        // Arrange
        final itemsWithDifferentMatches = [
          TestHelpers.generateMockMemoryItem(
            id: 'title-match',
            title: 'Flutter Development',
            content: 'Guide to mobile app development',
            tags: ['mobile'],
          ),
          TestHelpers.generateMockMemoryItem(
            id: 'content-match',
            title: 'Mobile Development',
            content: 'This guide covers Flutter framework extensively',
            tags: ['mobile'],
          ),
        ];
        
        final hiveItems = itemsWithDifferentMatches.map(HiveMemoryItem.fromDomain,
        ).toList();
        
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => hiveItems);

        // Act
        final result = await repository.getRelevantMemoryItems('Flutter');

        // Assert
        expect(result.length, equals(2));
        // Title match should have higher score than content match
        final titleMatchItem = result.firstWhere((item) => item.id == 'title-match');
        final contentMatchItem = result.firstWhere((item) => item.id == 'content-match');
        expect(titleMatchItem.relevanceScore! > contentMatchItem.relevanceScore!, isTrue);
      });

      test('should give recency bonus to recently updated items', () async {
        // Arrange
        final now = DateTime.now();
        final itemsWithDifferentDates = [
          TestHelpers.generateMockMemoryItem(
            id: 'recent-item',
            title: 'Flutter Guide',
            content: 'Recent Flutter guide',
            updatedAt: now.subtract(const Duration(days: 1)), // Very recent
          ),
          TestHelpers.generateMockMemoryItem(
            id: 'old-item',
            title: 'Flutter Guide',
            content: 'Old Flutter guide',
            updatedAt: now.subtract(const Duration(days: 60)), // Old
          ),
        ];
        
        final hiveItems = itemsWithDifferentDates.map(HiveMemoryItem.fromDomain,
        ).toList();
        
        when(() => mockHiveStorageLocalDataSource.getAllMemoryItems())
            .thenAnswer((_) async => hiveItems);

        // Act
        final result = await repository.getRelevantMemoryItems('Flutter');

        // Assert
        expect(result.length, equals(2));
        // Recent item should be ranked higher due to recency bonus
        expect(result.first.id, equals('recent-item'));
      });
    });
  });
} 
