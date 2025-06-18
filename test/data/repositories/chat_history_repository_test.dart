import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/models/hive_storage/hive_chat_session.dart';
import 'package:ai_chat_bot/data/repositories/impl_chat_history_repository.dart';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

/// Mock classes using mocktail
class MockHiveStorageLocalDataSource extends Mock implements HiveStorageLocalDataSource {}

void main() {
  group('ImplChatHistoryRepository', () {
    late ImplChatHistoryRepository repository;
    late MockHiveStorageLocalDataSource mockHiveStorageLocalDataSource;
    
    late List<ChatSessionEntity> mockChatSessions;
    late ChatSessionEntity mockChatSession;
    late List<HiveChatSession> mockHiveChatSessions;

    /// Setup before each test
    setUp(() {
      mockHiveStorageLocalDataSource = MockHiveStorageLocalDataSource();
      repository = ImplChatHistoryRepository(mockHiveStorageLocalDataSource);
      
      mockChatSessions = TestHelpers.generateMockChatSessions();
      mockChatSession = TestHelpers.generateMockChatSession();
      
      // Create mock Hive chat sessions
      mockHiveChatSessions = mockChatSessions.map((session) => 
        HiveChatSession.fromDomain(session)
      ).toList();

      // Register fallback values for mocktail
      registerFallbackValue(mockHiveChatSessions.first);
    });

    /// Cleanup after each test
    tearDown(() {
      repository.dispose();
    });

    group('getAllSessions', () {
      test('should return chat sessions from data source', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenAnswer((_) async => mockHiveChatSessions);

        // Act
        final result = await repository.getAllSessions();

        // Assert
        expect(result.length, equals(mockChatSessions.length));
        expect(result.first.id, equals(mockChatSessions.first.id));
        expect(result.first.title, equals(mockChatSessions.first.title));
        verify(() => mockHiveStorageLocalDataSource.getAllSessions()).called(1);
      });

      test('should handle empty list from data source', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllSessions();

        // Assert
        expect(result, isEmpty);
        verify(() => mockHiveStorageLocalDataSource.getAllSessions()).called(1);
      });

      test('should handle error from data source', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenThrow(Exception('Data source error'));

        // Act & Assert
        expect(() => repository.getAllSessions(), throwsException);
        verify(() => mockHiveStorageLocalDataSource.getAllSessions()).called(1);
      });
    });

    group('getSession', () {
      const testSessionId = 'test-session-id';

      test('should return chat session when found', () async {
        // Arrange
        final mockHiveSession = HiveChatSession.fromDomain(mockChatSession);
        when(() => mockHiveStorageLocalDataSource.getSession(testSessionId))
            .thenAnswer((_) async => mockHiveSession);

        // Act
        final result = await repository.getSession(testSessionId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(mockChatSession.id));
        expect(result.title, equals(mockChatSession.title));
        expect(result.messages.length, equals(mockChatSession.messages.length));
        verify(() => mockHiveStorageLocalDataSource.getSession(testSessionId)).called(1);
      });

      test('should return null when session not found', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getSession(testSessionId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getSession(testSessionId);

        // Assert
        expect(result, isNull);
        verify(() => mockHiveStorageLocalDataSource.getSession(testSessionId)).called(1);
      });

      test('should handle error from data source', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.getSession(testSessionId))
            .thenThrow(Exception('Session not found'));

        // Act & Assert
        expect(() => repository.getSession(testSessionId), throwsException);
        verify(() => mockHiveStorageLocalDataSource.getSession(testSessionId)).called(1);
      });
    });

    group('saveSession', () {
      test('should save chat session and notify stream', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.saveSession(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenAnswer((_) async => [HiveChatSession.fromDomain(mockChatSession)]);

        // Act
        await repository.saveSession(mockChatSession);

        // Assert
        verify(() => mockHiveStorageLocalDataSource.saveSession(any())).called(1);
        // Stream notification is tested separately due to async nature
      });

      test('should handle save error', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.saveSession(any()))
            .thenThrow(Exception('Save failed'));

        // Act & Assert
        expect(() => repository.saveSession(mockChatSession), throwsException);
        verify(() => mockHiveStorageLocalDataSource.saveSession(any())).called(1);
      });
    });

    group('deleteSession', () {
      const testSessionId = 'test-session-id';

      test('should delete chat session and notify stream', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.deleteSession(testSessionId))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenAnswer((_) async => []);

        // Act
        await repository.deleteSession(testSessionId);

        // Assert
        verify(() => mockHiveStorageLocalDataSource.deleteSession(testSessionId)).called(1);
      });

      test('should handle delete error', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.deleteSession(testSessionId))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(() => repository.deleteSession(testSessionId), throwsException);
        verify(() => mockHiveStorageLocalDataSource.deleteSession(testSessionId)).called(1);
      });
    });

    group('updateSession', () {
      test('should update chat session and notify stream', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.updateSession(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenAnswer((_) async => [HiveChatSession.fromDomain(mockChatSession)]);

        // Act
        await repository.updateSession(mockChatSession);

        // Assert
        verify(() => mockHiveStorageLocalDataSource.updateSession(any())).called(1);
      });

      test('should handle update error', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.updateSession(any()))
            .thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(() => repository.updateSession(mockChatSession), throwsException);
        verify(() => mockHiveStorageLocalDataSource.updateSession(any())).called(1);
      });
    });

    group('watchAllSessions', () {
      test('should provide stream of chat sessions', () {
        // Arrange & Act
        final stream = repository.watchAllSessions();

        // Assert
        expect(stream, isA<Stream<List<ChatSessionEntity>>>());
      });
    });

    group('stream notifications', () {
      test('should emit updated data after save operation', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.saveSession(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenAnswer((_) async => [HiveChatSession.fromDomain(mockChatSession)]);

        final stream = repository.watchAllSessions();
        
        // Act
        await repository.saveSession(mockChatSession);

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<ChatSessionEntity>>((sessions) => 
            sessions.isNotEmpty && sessions.first.id == mockChatSession.id
          )),
        );
      });

      test('should emit updated data after delete operation', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.deleteSession(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenAnswer((_) async => []);

        final stream = repository.watchAllSessions();
        
        // Act
        await repository.deleteSession('test-session-id');

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<ChatSessionEntity>>((sessions) => sessions.isEmpty)),
        );
      });

      test('should emit updated data after update operation', () async {
        // Arrange
        final updatedSession = mockChatSession.copyWith(title: 'Updated Title');
        when(() => mockHiveStorageLocalDataSource.updateSession(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenAnswer((_) async => [HiveChatSession.fromDomain(updatedSession)]);

        final stream = repository.watchAllSessions();
        
        // Act
        await repository.updateSession(updatedSession);

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<ChatSessionEntity>>((sessions) => 
            sessions.isNotEmpty && 
            sessions.first.id == updatedSession.id &&
            sessions.first.title == 'Updated Title'
          )),
        );
      });

      test('should handle stream errors gracefully', () async {
        // Arrange
        when(() => mockHiveStorageLocalDataSource.saveSession(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getAllSessions())
            .thenThrow(Exception('Stream error'));

        final stream = repository.watchAllSessions();
        
        // Act
        await repository.saveSession(mockChatSession);

        // Assert
        await expectLater(
          stream,
          emitsError(isA<Exception>()),
        );
      });
    });

    group('data integrity', () {
      test('should preserve session data during save and retrieve', () async {
        // Arrange
        final sessionWithComplexData = TestHelpers.generateMockChatSession(
          id: 'complex-session',
          title: 'Complex Session with Multiple Messages',
          messages: TestHelpers.generateMockChatMessages('complex-session'),
        );
        
        final hiveSession = HiveChatSession.fromDomain(sessionWithComplexData);
        
        when(() => mockHiveStorageLocalDataSource.saveSession(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getSession('complex-session'))
            .thenAnswer((_) async => hiveSession);

        // Act
        await repository.saveSession(sessionWithComplexData);
        final retrievedSession = await repository.getSession('complex-session');

        // Assert
        expect(retrievedSession, isNotNull);
        expect(retrievedSession!.id, equals(sessionWithComplexData.id));
        expect(retrievedSession.title, equals(sessionWithComplexData.title));
        expect(retrievedSession.messages.length, equals(sessionWithComplexData.messages.length));
        
        // Verify message content is preserved
        for (int i = 0; i < retrievedSession.messages.length; i++) {
          final originalMessage = sessionWithComplexData.messages[i];
          final retrievedMessage = retrievedSession.messages[i];
          
          expect(retrievedMessage.id, equals(originalMessage.id));
          expect(retrievedMessage.content, equals(originalMessage.content));
          expect(retrievedMessage.isUser, equals(originalMessage.isUser));
          expect(retrievedMessage.sessionId, equals(originalMessage.sessionId));
        }
      });

      test('should handle sessions with empty message lists', () async {
        // Arrange
        final emptySession = TestHelpers.generateMockChatSession(
          id: 'empty-session',
          title: 'Empty Session',
          messages: [],
        );
        
        final hiveSession = HiveChatSession.fromDomain(emptySession);
        
        when(() => mockHiveStorageLocalDataSource.saveSession(any()))
            .thenAnswer((_) async {});
        when(() => mockHiveStorageLocalDataSource.getSession('empty-session'))
            .thenAnswer((_) async => hiveSession);

        // Act
        await repository.saveSession(emptySession);
        final retrievedSession = await repository.getSession('empty-session');

        // Assert
        expect(retrievedSession, isNotNull);
        expect(retrievedSession!.messages, isEmpty);
        verify(() => mockHiveStorageLocalDataSource.saveSession(any())).called(1);
        verify(() => mockHiveStorageLocalDataSource.getSession('empty-session')).called(1);
      });
    });
  });
} 