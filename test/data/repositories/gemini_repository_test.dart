import 'package:ai_chat_bot/data/datasources/remote/gemini/gemini_remote_datasource.dart';
import 'package:ai_chat_bot/data/models/gemini/gemini_text_response.dart';
import 'package:ai_chat_bot/data/repositories/impl_gemini_repository.dart';
import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock classes using mocktail
class MockGeminiRemoteDataSource extends Mock implements GeminiRemoteDataSource {}

void main() {
  group('ImplGeminiRepository', () {
    late ImplGeminiRepository repository;
    late MockGeminiRemoteDataSource mockGeminiRemoteDataSource;

    /// Setup before each test
    setUp(() {
      mockGeminiRemoteDataSource = MockGeminiRemoteDataSource();
      repository = ImplGeminiRepository(mockGeminiRemoteDataSource);
    });

    group('generateResponse', () {
      const testPrompt = 'Tell me about Flutter development';

      test('should stream valid responses and convert to domain entities', () async {
        // Arrange
        final mockGeminiResponses = [
          const GeminiTextResponse(
            output: 'Flutter is a',
            isComplete: false,
            finishReason: null,
          ),
          const GeminiTextResponse(
            output: ' powerful UI',
            isComplete: false,
            finishReason: null,
          ),
          const GeminiTextResponse(
            output: ' toolkit',
            isComplete: true,
            finishReason: 'STOP',
          ),
        ];

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.fromIterable(mockGeminiResponses));

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results.length, equals(3));
        
        // Verify first response
        expect(results[0], isA<LLMTextResponseEntity>());
        expect(results[0]!.text, equals('Flutter is a'));
        expect(results[0]!.isComplete, isFalse);
        expect(results[0]!.finishReason, isNull);

        // Verify second response  
        expect(results[1]!.text, equals(' powerful UI'));
        expect(results[1]!.isComplete, isFalse);
        expect(results[1]!.finishReason, isNull);

        // Verify final response
        expect(results[2]!.text, equals(' toolkit'));
        expect(results[2]!.isComplete, isTrue);
        expect(results[2]!.finishReason, equals('STOP'));

        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });

      test('should handle null responses in stream gracefully', () async {
        // Arrange
        final mockResponsesWithNulls = [
          const GeminiTextResponse(
            output: 'Valid response',
            isComplete: false,
            finishReason: null,
          ),
          null, // Null response
          const GeminiTextResponse(
            output: 'Another valid response',
            isComplete: true,
            finishReason: 'STOP',
          ),
        ];

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.fromIterable(mockResponsesWithNulls));

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results.length, equals(3));
        
        // First response should be valid
        expect(results[0], isA<LLMTextResponseEntity>());
        expect(results[0]!.text, equals('Valid response'));
        
        // Second response should be null (passed through)
        expect(results[1], isNull);
        
        // Third response should be valid
        expect(results[2], isA<LLMTextResponseEntity>());
        expect(results[2]!.text, equals('Another valid response'));
        expect(results[2]!.isComplete, isTrue);

        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });

      test('should handle empty stream from data source', () async {
        // Arrange
        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => const Stream.empty());

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results, isEmpty);
        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });

      test('should handle stream with only null responses', () async {
        // Arrange
        final nullResponses = [null, null, null];

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.fromIterable(nullResponses));

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results.length, equals(3));
        expect(results.every((result) => result == null), isTrue);
        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });

      test('should handle empty text responses', () async {
        // Arrange
        final emptyResponses = [
          const GeminiTextResponse(
            output: '',
            isComplete: false,
            finishReason: null,
          ),
          const GeminiTextResponse(
            output: '',
            isComplete: true,
            finishReason: 'STOP',
          ),
        ];

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.fromIterable(emptyResponses));

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results.length, equals(2));
        expect(results[0]!.text, equals(''));
        expect(results[0]!.isComplete, isFalse);
        expect(results[1]!.text, equals(''));
        expect(results[1]!.isComplete, isTrue);
        expect(results[1]!.finishReason, equals('STOP'));

        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });

      test('should propagate stream errors from data source', () async {
        // Arrange
        final testError = Exception('Network error');
        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.error(testError));

        // Act & Assert
        final stream = repository.generateResponse(testPrompt);
        
        expect(
          () => stream.toList(),
          throwsA(isA<Exception>()),
        );

        // Note: No verify call needed as stream error prevents method completion
      });

      test('should handle mixed stream with errors and valid responses', () async {
        // Arrange
        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) async* {
              yield const GeminiTextResponse(
                output: 'First response',
                isComplete: false,
                finishReason: null,
              );
              
              yield* Stream.error(Exception('Temporary error'));
            });

        // Act & Assert
        final stream = repository.generateResponse(testPrompt);
        
        expect(
          () => stream.toList(),
          throwsA(isA<Exception>()),
        );

        // Note: No verify call needed as stream error prevents method completion
      });

      test('should handle responses with different finish reasons', () async {
        // Arrange
        final responsesWithDifferentFinishReasons = [
          const GeminiTextResponse(
            output: 'Response 1',
            isComplete: true,
            finishReason: 'STOP',
          ),
          const GeminiTextResponse(
            output: 'Response 2',
            isComplete: true,
            finishReason: 'MAX_TOKENS',
          ),
          const GeminiTextResponse(
            output: 'Response 3',
            isComplete: true,
            finishReason: 'SAFETY',
          ),
        ];

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.fromIterable(responsesWithDifferentFinishReasons));

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results.length, equals(3));
        expect(results[0]!.finishReason, equals('STOP'));
        expect(results[1]!.finishReason, equals('MAX_TOKENS'));
        expect(results[2]!.finishReason, equals('SAFETY'));
        
        // All should be marked as complete
        expect(results.every((result) => result!.isComplete), isTrue);

        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });

      test('should handle very long text responses', () async {
        // Arrange
        final longText = 'A' * 10000; // 10k characters
        final longResponse = GeminiTextResponse(
          output: longText,
          isComplete: true,
          finishReason: 'STOP',
        );

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.value(longResponse));

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results.length, equals(1));
        expect(results[0]!.text, equals(longText));
        expect(results[0]!.text.length, equals(10000));
        expect(results[0]!.isComplete, isTrue);

        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });

      test('should handle special characters and unicode in responses', () async {
        // Arrange
        const specialText = 'Hello 🌍! This is a test with émojis and ñon-ASCII characters: 你好';
        final specialResponse = GeminiTextResponse(
          output: specialText,
          isComplete: true,
          finishReason: 'STOP',
        );

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.value(specialResponse));

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results.length, equals(1));
        expect(results[0]!.text, equals(specialText));
        expect(results[0]!.isComplete, isTrue);

        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });
    });

    group('data conversion', () {
      test('should correctly convert GeminiTextResponse to LLMTextResponseEntity', () async {
        // Arrange
        const geminiResponse = GeminiTextResponse(
          output: 'Test response text',
          isComplete: true,
          finishReason: 'STOP',
        );

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(any()))
            .thenAnswer((_) => Stream.value(geminiResponse));

        // Act
        final stream = repository.generateResponse('test');
        final result = await stream.first;

        // Assert
        expect(result, isA<LLMTextResponseEntity>());
        expect(result!.text, equals('Test response text'));
        expect(result.isComplete, isTrue);
        expect(result.finishReason, equals('STOP'));
      });

      test('should handle null output in GeminiTextResponse', () async {
        // Arrange
        const geminiResponse = GeminiTextResponse(
          output: null,
          isComplete: false,
          finishReason: null,
        );

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(any()))
            .thenAnswer((_) => Stream.value(geminiResponse));

        // Act
        final stream = repository.generateResponse('test');
        final result = await stream.first;

        // Assert
        expect(result, isA<LLMTextResponseEntity>());
        expect(result!.text, equals('')); // Null output is converted to empty string
        expect(result.isComplete, isFalse);
        expect(result.finishReason, isNull);
      });
    });

    group('integration scenarios', () {
      const testPrompt = 'Tell me about Flutter development';
      
      test('should handle complete conversation flow', () async {
        // Arrange - Simulate a complete AI response generation
        final conversationFlow = [
          const GeminiTextResponse(output: 'I', isComplete: false),
          const GeminiTextResponse(output: ' understand', isComplete: false),
          const GeminiTextResponse(output: ' your', isComplete: false),
          const GeminiTextResponse(output: ' question', isComplete: false),
          const GeminiTextResponse(output: '.', isComplete: false),
          const GeminiTextResponse(output: ' Let', isComplete: false),
          const GeminiTextResponse(output: ' me', isComplete: false),
          const GeminiTextResponse(output: ' help', isComplete: false),
          const GeminiTextResponse(output: ' you', isComplete: false),
          const GeminiTextResponse(output: '.', isComplete: true, finishReason: 'STOP'),
        ];

        when(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt))
            .thenAnswer((_) => Stream.fromIterable(conversationFlow));

        // Act
        final stream = repository.generateResponse(testPrompt);
        final results = await stream.toList();

        // Assert
        expect(results.length, equals(10));
        
        // Check progressive text building
        expect(results[0]!.text, equals('I'));
        expect(results[1]!.text, equals(' understand'));
        expect(results[2]!.text, equals(' your'));
        expect(results[9]!.text, equals('.'));
        
        // Only the last response should be complete
        expect(results.sublist(0, 9).every((r) => !r!.isComplete), isTrue);
        expect(results[9]!.isComplete, isTrue);
        expect(results[9]!.finishReason, equals('STOP'));

        verify(() => mockGeminiRemoteDataSource.streamGenerateContent(testPrompt)).called(1);
      });
    });
  });
} 