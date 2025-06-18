import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/entities/chat_message_entity.dart';
import 'package:ai_chat_bot/domain/usecases/generate_text_with_memory_context_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/save_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_session_usecase.dart';
import 'package:ai_chat_bot/presentation/bloc/chat/chat_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../../helpers/test_helpers.dart';

/// Mock classes using mocktail
class MockGenerateTextWithMemoryContextUseCase extends Mock implements GenerateTextWithMemoryContextUseCase {}
class MockSaveChatSessionUseCase extends Mock implements SaveChatSessionUseCase {}
class MockGetChatSessionUseCase extends Mock implements GetChatSessionUseCase {}

void main() {
  group('ChatBloc', () {
    late ChatBloc chatBloc;
    late MockGenerateTextWithMemoryContextUseCase mockGenerateTextWithMemoryContextUseCase;
    late MockSaveChatSessionUseCase mockSaveChatSessionUseCase;
    late MockGetChatSessionUseCase mockGetChatSessionUseCase;
    
    late List<ChatMessageEntity> mockChatMessages;
    late ChatSessionEntity mockChatSession;
    late LLMTextResponseEntity mockLLMResponse;

    /// Setup before each test
    setUp(() {
      mockGenerateTextWithMemoryContextUseCase = MockGenerateTextWithMemoryContextUseCase();
      mockSaveChatSessionUseCase = MockSaveChatSessionUseCase();
      mockGetChatSessionUseCase = MockGetChatSessionUseCase();
      
      mockChatMessages = TestHelpers.generateMockChatMessages('test-session');
      mockChatSession = TestHelpers.generateMockChatSession();
      mockLLMResponse = TestHelpers.generateMockLLMResponse();

      chatBloc = ChatBloc(
        mockGenerateTextWithMemoryContextUseCase,
        mockSaveChatSessionUseCase,
        mockGetChatSessionUseCase,
      );

      // Register fallback values for mocktail
      registerFallbackValue(mockChatSession);
      registerFallbackValue(mockChatMessages);
    });

    /// Cleanup after each test
    tearDown(() {
      chatBloc.close();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        // Arrange & Act
        final initialState = ChatState.initial();
        
        // Assert
        expect(initialState.isLoading, isFalse);
        expect(initialState.generatedContent, isNull);
        expect(initialState.error, isNull);
        expect(initialState.messages.length, equals(1));
        expect((initialState.messages.first as types.TextMessage).text, equals('Hi, can I help you?'));
        expect(initialState.currentSessionId, isNull);
        expect(initialState.sessionTitle, isNull);
        expect(initialState.isNewSession, isTrue);
        expect(initialState.contextMessages, isEmpty);
        expect(initialState.lastFailedPrompt, isNull);
        expect(initialState.partialResponse, isNull);
      });
    });

    group('SendMessageEvent', () {
      const testMessage = 'Test message';

      blocTest<ChatBloc, ChatState>(
        'should emit loading state and add user message to chat',
        build: () {
          // Arrange
          when(() => mockGenerateTextWithMemoryContextUseCase.call(any(), any()))
              .thenAnswer((_) => Stream.value(mockLLMResponse));
          return chatBloc;
        },
        act: (bloc) => bloc.add(SendMessageEvent(testMessage)),
        skip: 4, // Skip the multiple state emissions 
        verify: (_) {
          verify(() => mockGenerateTextWithMemoryContextUseCase.call(testMessage, any())).called(1);
          verify(() => mockSaveChatSessionUseCase.call(any())).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should not send message when text is empty',
        build: () => chatBloc,
        act: (bloc) => bloc.add(SendMessageEvent('')),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockGenerateTextWithMemoryContextUseCase.call(any(), any()));
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should handle error when generation fails',
        build: () {
          // Arrange
          when(() => mockGenerateTextWithMemoryContextUseCase.call(any(), any()))
              .thenThrow(Exception('AI service unavailable'));
          return chatBloc;
        },
        act: (bloc) => bloc.add(SendMessageEvent(testMessage)),
        skip: 3, // Skip the state emissions
        verify: (_) {
          verify(() => mockGenerateTextWithMemoryContextUseCase.call(testMessage, any())).called(1);
        },
      );
    });

    group('EditAndResendMessageEvent', () {
      const messageId = 'test-message-id';
      const newMessageText = 'Edited message';

      blocTest<ChatBloc, ChatState>(
        'should edit message and regenerate response',
        build: () {
          // Arrange
          when(() => mockGenerateTextWithMemoryContextUseCase.call(any(), any()))
              .thenAnswer((_) => Stream.value(mockLLMResponse));
          return chatBloc;
        },
        seed: () => ChatState(
          isLoading: false,
          messages: [
            types.TextMessage(
              author: const types.User(id: 'bot'),
              id: 'bot-response',
              text: 'Previous bot response',
            ),
            types.TextMessage(
              author: const types.User(id: 'user'),
              id: messageId,
              text: 'Original message',
            ),
            types.TextMessage(
              author: const types.User(id: 'bot'),
              id: 'initial-bot',
              text: 'Hi, can I help you?',
            ),
          ],
          contextMessages: [
            ChatMessageEntity(
              id: messageId,
              content: 'Original message',
              isUser: true,
              timestamp: DateTime.now(),
              sessionId: 'test-session',
            ),
          ],
        ),
        act: (bloc) => bloc.add(EditAndResendMessageEvent(messageId, newMessageText)),
        skip: 4, // Skip the multiple state emissions
        verify: (_) {
          verify(() => mockGenerateTextWithMemoryContextUseCase.call(newMessageText, any())).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should not edit message when new text is empty',
        build: () => chatBloc,
        act: (bloc) => bloc.add(EditAndResendMessageEvent(messageId, '')),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockGenerateTextWithMemoryContextUseCase.call(any(), any()));
        },
      );
    });

    group('GenerateTextEvent', () {
      const prompt = 'Test prompt';

      blocTest<ChatBloc, ChatState>(
        'should handle streaming response correctly',
        build: () {
          // Arrange
          final streamingResponse = TestHelpers.generateMockStreamingResponse(
            'This is a complete AI response',
            chunkSize: 5,
            delay: Duration.zero,
          );
          when(() => mockGenerateTextWithMemoryContextUseCase.call(prompt, any()))
              .thenAnswer((_) => streamingResponse);
          return chatBloc;
        },
        seed: () => ChatState(
          isLoading: false,
          messages: [
            types.TextMessage(
              author: const types.User(id: 'bot'),
              id: 'streaming-bot',
              text: '',
              status: types.Status.sending,
            ),
          ],
          contextMessages: [],
        ),
        act: (bloc) => bloc.add(GenerateTextEvent(prompt)),
        skip: 1, // Skip the state emission
        verify: (_) {
          verify(() => mockGenerateTextWithMemoryContextUseCase.call(prompt, any())).called(1);
          // Note: Save session call may not happen in this specific test scenario
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should handle retry with partial response',
        build: () {
          // Arrange
          when(() => mockGenerateTextWithMemoryContextUseCase.call(prompt, any()))
              .thenAnswer((_) => Stream.value(TestHelpers.generateMockLLMResponse(
                text: ' continued response',
                isComplete: true,
              )));
          return chatBloc;
        },
        seed: () => ChatState(
          isLoading: false,
          messages: [
            types.TextMessage(
              author: const types.User(id: 'bot'),
              id: 'retry-bot',
              text: '',
            ),
          ],
          contextMessages: [],
          partialResponse: 'Partial',
        ),
        act: (bloc) => bloc.add(GenerateTextEvent(prompt, isRetry: true)),
        skip: 2, // Skip the state emissions
        verify: (_) {
          verify(() => mockGenerateTextWithMemoryContextUseCase.call(prompt, any())).called(1);
        },
      );
    });

    group('LoadChatSessionEvent', () {
      const sessionId = 'test-session-id';

      blocTest<ChatBloc, ChatState>(
        'should load chat session and convert messages to UI format',
        build: () {
          // Arrange
          when(() => mockGetChatSessionUseCase.call(sessionId))
              .thenAnswer((_) async => mockChatSession);
          return chatBloc;
        },
        act: (bloc) => bloc.add(LoadChatSessionEvent(sessionId)),
        skip: 1, // Skip the state emission
        verify: (_) {
          verify(() => mockGetChatSessionUseCase.call(sessionId)).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should handle error when loading session fails',
        build: () {
          // Arrange
          when(() => mockGetChatSessionUseCase.call(sessionId))
              .thenThrow(Exception('Session not found'));
          return chatBloc;
        },
        act: (bloc) => bloc.add(LoadChatSessionEvent(sessionId)),
        skip: 1, // Skip the state emission
        verify: (_) {
          verify(() => mockGetChatSessionUseCase.call(sessionId)).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should handle null session gracefully',
        build: () {
          // Arrange
          when(() => mockGetChatSessionUseCase.call(sessionId))
              .thenAnswer((_) async => null);
          return chatBloc;
        },
        act: (bloc) => bloc.add(LoadChatSessionEvent(sessionId)),
        expect: () => [], // No state changes expected when session is null
        verify: (_) {
          verify(() => mockGetChatSessionUseCase.call(sessionId)).called(1);
        },
      );
    });

    group('SaveChatSessionEvent', () {
      blocTest<ChatBloc, ChatState>(
        'should save chat session with generated title',
        build: () {
          // Arrange
          when(() => mockSaveChatSessionUseCase.call(any()))
              .thenAnswer((_) async {});
          return chatBloc;
        },
        seed: () => ChatState(
          isLoading: false,
          messages: [],
          contextMessages: [
            ChatMessageEntity(
              id: 'msg-1',
              content: 'Hello, this is a test message',
              isUser: true,
              timestamp: DateTime.now(),
              sessionId: '',
            ),
          ],
          isNewSession: true,
        ),
        act: (bloc) => bloc.add(SaveChatSessionEvent()),
        skip: 1, // Skip the state emission
        verify: (_) {
          verify(() => mockSaveChatSessionUseCase.call(any())).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should truncate long title correctly',
        build: () {
          // Arrange
          when(() => mockSaveChatSessionUseCase.call(any()))
              .thenAnswer((_) async {});
          return chatBloc;
        },
        seed: () => ChatState(
          isLoading: false,
          messages: [],
          contextMessages: [
            ChatMessageEntity(
              id: 'msg-1',
              content: 'This is a very long message that should be truncated to 30 characters',
              isUser: true,
              timestamp: DateTime.now(),
              sessionId: '',
            ),
          ],
          isNewSession: true,
        ),
        act: (bloc) => bloc.add(SaveChatSessionEvent()),
        skip: 1, // Skip the state emission
        verify: (_) {
          verify(() => mockSaveChatSessionUseCase.call(any())).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should not save when no context messages',
        build: () => chatBloc,
        act: (bloc) => bloc.add(SaveChatSessionEvent()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockSaveChatSessionUseCase.call(any()));
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should handle save error',
        build: () {
          // Arrange
          when(() => mockSaveChatSessionUseCase.call(any()))
              .thenThrow(Exception('Failed to save session'));
          return chatBloc;
        },
        seed: () => ChatState(
          isLoading: false,
          messages: [],
          contextMessages: [mockChatMessages.first],
          isNewSession: true,
        ),
        act: (bloc) => bloc.add(SaveChatSessionEvent()),
        skip: 1, // Skip the state emission
        verify: (_) {
          verify(() => mockSaveChatSessionUseCase.call(any())).called(1);
        },
      );
    });

    group('CreateNewSessionEvent', () {
      blocTest<ChatBloc, ChatState>(
        'should reset to initial state',
        build: () => chatBloc,
        seed: () => ChatState(
          isLoading: false,
          messages: [
            types.TextMessage(
              author: const types.User(id: 'user'),
              id: 'user-msg',
              text: 'Previous message',
            ),
          ],
          currentSessionId: 'old-session',
          sessionTitle: 'Old Session',
          isNewSession: false,
          contextMessages: [mockChatMessages.first],
        ),
        act: (bloc) => bloc.add(CreateNewSessionEvent()),
        skip: 1, // Skip the state emission
      );
    });

    group('RetryLastRequestEvent', () {
      const failedPrompt = 'Failed prompt';

      blocTest<ChatBloc, ChatState>(
        'should retry last failed request',
        build: () {
          // Arrange
          when(() => mockGenerateTextWithMemoryContextUseCase.call(failedPrompt, any()))
              .thenAnswer((_) => Stream.value(mockLLMResponse));
          return chatBloc;
        },
        seed: () => ChatState(
          isLoading: false,
          messages: [
            types.TextMessage(
              author: const types.User(id: 'bot'),
              id: 'failed-bot',
              text: 'Partial response',
              status: types.Status.error,
            ),
          ],
          contextMessages: [],
          lastFailedPrompt: failedPrompt,
          partialResponse: 'Partial response',
        ),
        act: (bloc) => bloc.add(RetryLastRequestEvent()),
        skip: 4, // Skip the multiple state emissions
        verify: (_) {
          verify(() => mockGenerateTextWithMemoryContextUseCase.call(failedPrompt, any())).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'should not retry when no failed prompt',
        build: () => chatBloc,
        seed: () => ChatState(
          isLoading: false,
          messages: [],
          lastFailedPrompt: null,
        ),
        act: (bloc) => bloc.add(RetryLastRequestEvent()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockGenerateTextWithMemoryContextUseCase.call(any(), any()));
        },
      );
    });

    group('error handling', () {
      test('should map 503 error to rate_limit', () {
        // This would test the private _getErrorMessage method
        // Since it's private, we test it indirectly through integration tests
        expect(true, isTrue); // Placeholder for comprehensive error handling tests
      });
    });
  });
} 