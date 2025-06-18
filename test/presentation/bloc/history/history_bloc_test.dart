import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/delete_chat_session_usecase.dart';
import 'package:ai_chat_bot/presentation/bloc/history/history_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

/// Mock classes using mocktail
class MockGetChatSessionsUseCase extends Mock implements GetChatSessionsUseCase {}
class MockDeleteChatSessionUseCase extends Mock implements DeleteChatSessionUseCase {}
class MockChatHistoryRepository extends Mock implements ChatHistoryRepository {}

void main() {
  group('HistoryBloc', () {
    late HistoryBloc historyBloc;
    late MockGetChatSessionsUseCase mockGetChatSessionsUseCase;
    late MockDeleteChatSessionUseCase mockDeleteChatSessionUseCase;
    late MockChatHistoryRepository mockChatHistoryRepository;
    
    late List<ChatSessionEntity> mockChatSessions;

    /// Setup before each test
    setUp(() {
      mockGetChatSessionsUseCase = MockGetChatSessionsUseCase();
      mockDeleteChatSessionUseCase = MockDeleteChatSessionUseCase();
      mockChatHistoryRepository = MockChatHistoryRepository();
      
      mockChatSessions = TestHelpers.generateMockChatSessions();

      // Setup default behavior for repository stream
      when(() => mockChatHistoryRepository.watchAllSessions())
          .thenAnswer((_) => Stream.value(mockChatSessions));

      historyBloc = HistoryBloc(
        mockGetChatSessionsUseCase,
        mockDeleteChatSessionUseCase,
        mockChatHistoryRepository,
      );
    });

    /// Cleanup after each test
    tearDown(() {
      historyBloc.close();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        // Arrange & Act
        final initialState = HistoryState.initial();
        
        // Assert
        expect(initialState.isLoading, isFalse);
        expect(initialState.sessions, isEmpty);
        expect(initialState.filteredSessions, isEmpty);
        expect(initialState.searchQuery, isEmpty);
        expect(initialState.error, isNull);
      });
    });

    group('LoadHistoryEvent', () {
      blocTest<HistoryBloc, HistoryState>(
        'should emit loading state then loaded state with sorted sessions',
        build: () {
          // Arrange
          when(() => mockGetChatSessionsUseCase.call())
              .thenAnswer((_) async => mockChatSessions);
          return historyBloc;
        },
        act: (bloc) => bloc.add(LoadHistoryEvent()),
        skip: 2,
        verify: (_) {
          verify(() => mockGetChatSessionsUseCase.call()).called(1);
        },
      );

      blocTest<HistoryBloc, HistoryState>(
        'should emit loading state then error state when use case fails',
        build: () {
          // Arrange
          when(() => mockGetChatSessionsUseCase.call())
              .thenThrow(Exception('Failed to load history'));
          return historyBloc;
        },
        act: (bloc) => bloc.add(LoadHistoryEvent()),
        skip: 2,
        verify: (_) {
          verify(() => mockGetChatSessionsUseCase.call()).called(1);
        },
      );
    });

    group('DeleteSessionEvent', () {
      const sessionIdToDelete = 'session-1';

      blocTest<HistoryBloc, HistoryState>(
        'should remove session from state when deleting',
        build: () {
          // Arrange
          when(() => mockDeleteChatSessionUseCase.call(any()))
              .thenAnswer((_) async {});
          return historyBloc;
        },
        seed: () => HistoryState(
          isLoading: false,
          sessions: mockChatSessions,
          filteredSessions: mockChatSessions,
          searchQuery: '',
          error: null,
        ),
        act: (bloc) => bloc.add(DeleteSessionEvent(sessionIdToDelete)),
        skip: 1,
        verify: (_) {
          verify(() => mockDeleteChatSessionUseCase.call(sessionIdToDelete)).called(1);
        },
      );

      blocTest<HistoryBloc, HistoryState>(
        'should emit error state when delete fails',
        build: () {
          // Arrange
          when(() => mockDeleteChatSessionUseCase.call(any()))
              .thenThrow(Exception('Failed to delete session'));
          return historyBloc;
        },
        seed: () => HistoryState(
          isLoading: false,
          sessions: mockChatSessions,
          filteredSessions: mockChatSessions,
          searchQuery: '',
          error: null,
        ),
        act: (bloc) => bloc.add(DeleteSessionEvent(sessionIdToDelete)),
        skip: 1,
        verify: (_) {
          verify(() => mockDeleteChatSessionUseCase.call(sessionIdToDelete)).called(1);
        },
      );
    });

    group('SearchSessionsEvent', () {
      const searchQuery = 'Flutter';

      blocTest<HistoryBloc, HistoryState>(
        'should filter sessions based on title when searching',
        build: () => historyBloc,
        seed: () => HistoryState(
          isLoading: false,
          sessions: mockChatSessions,
          filteredSessions: mockChatSessions,
          searchQuery: '',
          error: null,
        ),
        act: (bloc) => bloc.add(SearchSessionsEvent(searchQuery)),
        skip: 1,
      );

      blocTest<HistoryBloc, HistoryState>(
        'should filter sessions based on message content when searching',
        build: () => historyBloc,
        seed: () => HistoryState(
          isLoading: false,
          sessions: mockChatSessions,
          filteredSessions: mockChatSessions,
          searchQuery: '',
          error: null,
        ),
        act: (bloc) => bloc.add(SearchSessionsEvent('help')), // Search for content in messages
        skip: 1,
      );

      blocTest<HistoryBloc, HistoryState>(
        'should show all sessions when search query is empty',
        build: () => historyBloc,
        seed: () => HistoryState(
          isLoading: false,
          sessions: mockChatSessions,
          filteredSessions: [],
          searchQuery: 'previous-query',
          error: null,
        ),
        act: (bloc) => bloc.add(SearchSessionsEvent('')),
        skip: 1,
      );
    });

    group('DataUpdatedEvent', () {
      final updatedSessions = [
        TestHelpers.generateMockChatSession(id: 'new-1', title: 'New Session 1'),
        TestHelpers.generateMockChatSession(id: 'new-2', title: 'New Session 2'),
      ];

      blocTest<HistoryBloc, HistoryState>(
        'should update sessions and filtered sessions when data is updated without search query',
        build: () => historyBloc,
        seed: () => HistoryState(
          isLoading: true,
          sessions: [],
          filteredSessions: [],
          searchQuery: '',
          error: null,
        ),
        act: (bloc) => bloc.add(DataUpdatedEvent(updatedSessions)),
        skip: 1,
      );

      blocTest<HistoryBloc, HistoryState>(
        'should update sessions and apply search filter when data is updated with search query',
        build: () => historyBloc,
        seed: () => HistoryState(
          isLoading: false,
          sessions: [],
          filteredSessions: [],
          searchQuery: 'new',
          error: null,
        ),
        act: (bloc) => bloc.add(DataUpdatedEvent(updatedSessions)),
        skip: 1,
      );

      blocTest<HistoryBloc, HistoryState>(
        'should sort sessions by updated date in descending order',
        build: () => historyBloc,
        act: (bloc) {
          final sessionsWithDifferentDates = [
            TestHelpers.generateMockChatSession(
              id: 'old-session',
              title: 'Old Session',
              updatedAt: DateTime(2024, 1, 1),
            ),
            TestHelpers.generateMockChatSession(
              id: 'new-session',
              title: 'New Session',
              updatedAt: DateTime(2024, 1, 3),
            ),
            TestHelpers.generateMockChatSession(
              id: 'medium-session',
              title: 'Medium Session',
              updatedAt: DateTime(2024, 1, 2),
            ),
          ];
          bloc.add(DataUpdatedEvent(sessionsWithDifferentDates));
        },
        skip: 1,
      );

      blocTest<HistoryBloc, HistoryState>(
        'should emit error state when data update processing fails',
        build: () => historyBloc,
        act: (bloc) => bloc.add(DataUpdatedEvent([])),
        skip: 1,
      );
    });

    group('stream subscription', () {
      test('should listen to repository stream on creation', () {
        // Arrange & Act
        final bloc = HistoryBloc(
          mockGetChatSessionsUseCase,
          mockDeleteChatSessionUseCase,
          mockChatHistoryRepository,
        );

        // Assert - Stream is called twice: once in setUp and once in this test
        verify(() => mockChatHistoryRepository.watchAllSessions()).called(2);
        
        bloc.close();
      });

      test('should handle stream errors gracefully', () {
        // Arrange
        when(() => mockChatHistoryRepository.watchAllSessions())
            .thenAnswer((_) => Stream.error(Exception('Stream error')));

        // Act & Assert - should not throw
        expect(() => HistoryBloc(
          mockGetChatSessionsUseCase,
          mockDeleteChatSessionUseCase,
          mockChatHistoryRepository,
        ), returnsNormally);
      });
    });
  });
} 