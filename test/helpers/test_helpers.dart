import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/domain/entities/chat_message_entity.dart';
import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';

/// Test helpers and mock data generators
class TestHelpers {
  /// Mock memory items
  static List<MemoryItemEntity> generateMockMemoryItems() {
    return [
      MemoryItemEntity(
        id: '1',
        title: 'Flutter Bloc Pattern',
        content: 'Bloc pattern is a design pattern for state management in Flutter applications.',
        tags: ['flutter', 'bloc', 'state-management'],
        createdAt: DateTime(2024, 1, 1, 10),
        updatedAt: DateTime(2024, 1, 2, 14, 30),
        relevanceScore: 0.9,
      ),
      MemoryItemEntity(
        id: '2',
        title: 'Unit Testing Best Practices',
        content: 'Unit tests should be fast, isolated, repeatable, self-validating, and timely.',
        tags: ['testing', 'best-practices', 'unit-testing'],
        createdAt: DateTime(2024, 1, 3, 9, 15),
        updatedAt: DateTime(2024, 1, 4, 16, 45),
        relevanceScore: 0.8,
      ),
      MemoryItemEntity(
        id: '3',
        title: 'Clean Architecture',
        content: 'Clean architecture separates concerns into layers: presentation, domain, and data.',
        tags: ['architecture', 'clean-code', 'design-patterns'],
        createdAt: DateTime(2024, 1, 5, 11, 30),
        updatedAt: DateTime(2024, 1, 6, 13, 20),
        relevanceScore: 0.7,
      ),
    ];
  }

  /// Mock single memory item
  static MemoryItemEntity generateMockMemoryItem({
    String id = 'test-id',
    String title = 'Test Title',
    String content = 'Test content for memory item',
    List<String> tags = const ['test', 'mock'],
    DateTime? createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
  }) {
    final now = DateTime.now();
    return MemoryItemEntity(
      id: id,
      title: title,
      content: content,
      tags: tags,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      relevanceScore: relevanceScore,
    );
  }

  /// Mock chat messages
  static List<ChatMessageEntity> generateMockChatMessages(String sessionId) {
    return [
      ChatMessageEntity(
        id: 'msg-1',
        content: 'Hello, how can I help you with Flutter?',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 10),
        sessionId: sessionId,
      ),
      ChatMessageEntity(
        id: 'msg-2',
        content: 'I can help you with Flutter development, state management, and best practices.',
        isUser: false,
        timestamp: DateTime(2024, 1, 1, 10, 1),
        sessionId: sessionId,
      ),
      ChatMessageEntity(
        id: 'msg-3',
        content: 'Tell me about the Bloc pattern',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 10, 2),
        sessionId: sessionId,
      ),
    ];
  }

  /// Mock chat sessions
  static List<ChatSessionEntity> generateMockChatSessions() {
    return [
      ChatSessionEntity(
        id: 'session-1',
        title: 'Flutter Development Discussion',
        createdAt: DateTime(2024, 1, 1, 10),
        updatedAt: DateTime(2024, 1, 1, 10, 30),
        messages: generateMockChatMessages('session-1'),
      ),
      ChatSessionEntity(
        id: 'session-2',
        title: 'State Management Patterns',
        createdAt: DateTime(2024, 1, 2, 14),
        updatedAt: DateTime(2024, 1, 2, 14, 45),
        messages: generateMockChatMessages('session-2'),
      ),
      ChatSessionEntity(
        id: 'session-3',
        title: 'Testing Strategies',
        createdAt: DateTime(2024, 1, 3, 9),
        updatedAt: DateTime(2024, 1, 3, 9, 20),
        messages: generateMockChatMessages('session-3'),
      ),
    ];
  }

  /// Mock single chat session
  static ChatSessionEntity generateMockChatSession({
    String id = 'test-session',
    String title = 'Test Session',
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessageEntity>? messages,
  }) {
    final now = DateTime.now();
    return ChatSessionEntity(
      id: id,
      title: title,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      messages: messages ?? generateMockChatMessages(id),
    );
  }

  /// Mock LLM text response
  static LLMTextResponseEntity generateMockLLMResponse({
    String text = 'Mock AI response',
    bool isComplete = true,
    String? finishReason,
  }) {
    return LLMTextResponseEntity(
      text: text,
      isComplete: isComplete,
      finishReason: finishReason,
    );
  }

  /// Generate streaming LLM responses for testing
  static Stream<LLMTextResponseEntity> generateMockStreamingResponse(
    String fullText, {
    int chunkSize = 10,
    Duration delay = const Duration(milliseconds: 100),
  }) async* {
    for (var i = 0; i < fullText.length; i += chunkSize) {
      await Future.delayed(delay);
      final chunk = fullText.substring(i, (i + chunkSize).clamp(0, fullText.length));
      final isComplete = i + chunkSize >= fullText.length;
      yield LLMTextResponseEntity(
        text: chunk,
        isComplete: isComplete,
        finishReason: isComplete ? 'STOP' : null,
      );
    }
  }

  /// Mock empty memory items list
  static List<MemoryItemEntity> generateEmptyMemoryItems() => [];

  /// Mock empty chat sessions list
  static List<ChatSessionEntity> generateEmptyChatSessions() => [];
} 
