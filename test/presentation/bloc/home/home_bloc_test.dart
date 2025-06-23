import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:ai_chat_bot/presentation/bloc/home/home_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

/// Mock classes using mocktail
class MockGetChatSessionsUseCase extends Mock implements GetChatSessionsUseCase {}
class MockChatHistoryRepository extends Mock implements ChatHistoryRepository {}

void main() {
  group('HomeBloc', () {
    late HomeBloc homeBloc;
    late MockGetChatSessionsUseCase mockGetChatSessionsUseCase;
    late MockChatHistoryRepository mockChatHistoryRepository;
    
    late List<ChatSessionEntity> mockChatSessions;

    /// Setup before each test
    setUp(() {
      mockGetChatSessionsUseCase = MockGetChatSessionsUseCase();
      mockChatHistoryRepository = MockChatHistoryRepository();
      
      mockChatSessions = TestHelpers.generateMockChatSessions();

      // Setup default behavior for repository stream
      when(() => mockChatHistoryRepository.watchAllSessions())
          .thenAnswer((_) => Stream.value(mockChatSessions));

      homeBloc = HomeBloc(
        mockGetChatSessionsUseCase,
        mockChatHistoryRepository,
      );
    });

    /// Cleanup after each test
    tearDown(() {
      homeBloc.close();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        // Arrange & Act
        final initialState = HomeState.initial();
        
        // Assert
        expect(initialState.isLoading, isFalse);
        expect(initialState.recentSessions, isEmpty);
        expect(initialState.error, isNull);
      });
    });

    group('LoadRecentHistoryEvent', () {
      blocTest<HomeBloc, HomeState>(
        'should emit loading state then loaded state with recent sessions',
        build: () {
          // Arrange
          when(() => mockGetChatSessionsUseCase.call())
              .thenAnswer((_) async => mockChatSessions);
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadRecentHistoryEvent()),
        expect: () => [
          predicate<HomeState>((state) => 
            state.isLoading && 
            state.recentSessions.length <= 5
          ),
          predicate<HomeState>((state) => 
            !state.isLoading && 
            state.recentSessions.length <= 5 &&
            state.error == null
          ),
        ],
        verify: (_) {
          verify(() => mockGetChatSessionsUseCase.call()).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'should emit loading state then error state when use case fails',
        build: () {
          // Arrange
          when(() => mockGetChatSessionsUseCase.call())
              .thenThrow(Exception('Failed to load chat sessions'));
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadRecentHistoryEvent()),
        expect: () => [
          predicate<HomeState>((state) => 
            state.isLoading
          ),
          predicate<HomeState>((state) => 
            !state.isLoading && 
            state.error != null &&
            state.error!.contains('Failed to load chat sessions')
          ),
        ],
        verify: (_) {
          verify(() => mockGetChatSessionsUseCase.call()).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'should limit recent sessions to 5 items',
        build: () {
          // Arrange
          final manySessions = List.generate(10, (index) => 
            TestHelpers.generateMockChatSession(
              id: 'session-$index',
              title: 'Session $index',
              updatedAt: DateTime.now().subtract(Duration(days: index)),
            ),
          );
          when(() => mockGetChatSessionsUseCase.call())
              .thenAnswer((_) async => manySessions);
          return homeBloc;
        },
        act: (bloc) => bloc.add(LoadRecentHistoryEvent()),
        expect: () => [
          predicate<HomeState>((state) => 
            state.isLoading
          ),
          predicate<HomeState>((state) => 
            !state.isLoading && 
            state.recentSessions.length == 5 && 
            state.error == null
          ),
        ],
        verify: (_) {
          verify(() => mockGetChatSessionsUseCase.call()).called(1);
        },
      );
    });

    group('RefreshRecentHistoryEvent', () {
      blocTest<HomeBloc, HomeState>(
        'should refresh recent sessions without loading state',
        build: () {
          // Arrange
          when(() => mockGetChatSessionsUseCase.call())
              .thenAnswer((_) async => mockChatSessions);
          return homeBloc;
        },
        seed: () => HomeState(
          isLoading: false,
          recentSessions: [],
          error: 'Previous error',
        ),
        act: (bloc) => bloc.add(RefreshRecentHistoryEvent()),
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          verify(() => mockGetChatSessionsUseCase.call()).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'should handle refresh error',
        build: () {
          // Arrange
          when(() => mockGetChatSessionsUseCase.call())
              .thenThrow(Exception('Failed to refresh sessions'));
          return homeBloc;
        },
        act: (bloc) => bloc.add(RefreshRecentHistoryEvent()),
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          verify(() => mockGetChatSessionsUseCase.call()).called(1);
        },
      );
    });

    group('DataUpdatedEvent', () {
      final updatedSessions = [
        TestHelpers.generateMockChatSession(id: 'new-1', title: 'New Session 1'),
        TestHelpers.generateMockChatSession(id: 'new-2', title: 'New Session 2'),
      ];

      blocTest<HomeBloc, HomeState>(
        'should update recent sessions when data is updated',
        build: () => homeBloc,
        seed: () => HomeState(
          isLoading: true,
          recentSessions: [],
        ),
        act: (bloc) => bloc.add(DataUpdatedEvent(updatedSessions)),
        expect: () => [
          predicate<HomeState>((state) => 
            !state.isLoading &&
            state.recentSessions.length == 2 &&
            state.recentSessions.any((s) => s.id == 'new-1') &&
            state.recentSessions.any((s) => s.id == 'new-2')
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should sort sessions by updated date in descending order',
        build: () => homeBloc,
        act: (bloc) {
          final sessionsWithDifferentDates = [
            TestHelpers.generateMockChatSession(
              id: 'old-session',
              title: 'Old Session',
              updatedAt: DateTime(2024),
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
        expect: () => [
          predicate<HomeState>((state) => 
            !state.isLoading && 
            state.recentSessions.length == 3 &&
            state.recentSessions[0].id == 'new-session' &&
            state.recentSessions[1].id == 'medium-session' &&
            state.recentSessions[2].id == 'old-session'
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should limit to 5 recent sessions when more are provided',
        build: () => homeBloc,
        act: (bloc) {
          final manySessions = List.generate(10, (index) => 
            TestHelpers.generateMockChatSession(
              id: 'session-$index',
              title: 'Session $index',
              updatedAt: DateTime.now().subtract(Duration(days: index)),
            ),
          );
          bloc.add(DataUpdatedEvent(manySessions));
        },
        expect: () => [
          predicate<HomeState>((state) => 
            !state.isLoading && 
            state.recentSessions.length == 5
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'should handle data update processing error',
        build: () => homeBloc,
        act: (bloc) => bloc.add(DataUpdatedEvent([])),
        expect: () => [
          predicate<HomeState>((state) => 
            !state.isLoading &&
            state.recentSessions.isEmpty
          ),
        ],
      );
    });

    group('stream subscription', () {
      test('should listen to repository stream on creation', () {
        // Arrange & Act
        final bloc = HomeBloc(
          mockGetChatSessionsUseCase,
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
        expect(() => HomeBloc(
          mockGetChatSessionsUseCase,
          mockChatHistoryRepository,
        ), returnsNormally);
      });
    });
  });
} 
