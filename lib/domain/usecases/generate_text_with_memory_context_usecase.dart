import 'dart:async';

import '../entities/llm_text_response_entity.dart';
import '../entities/chat_message_entity.dart';
import '../entities/memory_item_entity.dart';
import '../repositories/llm/llm_repository.dart';
import 'get_relevant_memory_for_context_usecase.dart';

class GenerateTextWithMemoryContextUseCase {
  final LLMRepository _llmRepository;
  final GetRelevantMemoryForContextUseCase _getRelevantMemoryUseCase;

  GenerateTextWithMemoryContextUseCase(
    this._llmRepository,
    this._getRelevantMemoryUseCase,
  );

  Stream<LLMTextResponseEntity?> call(
    String prompt,
    List<ChatMessageEntity> chatContext,
  ) async* {
    // 1. Get relevant memories based on prompt
    final relevantMemories = await _getRelevantMemoryUseCase.call(prompt);

    // 2. Build enhanced context with memories + chat history
    final enhancedPrompt = _buildEnhancedPrompt(prompt, chatContext, relevantMemories);

    // 3. Generate response with enhanced context
    yield* _llmRepository.generateResponse(enhancedPrompt);
  }

  String _buildEnhancedPrompt(
    String prompt,
    List<ChatMessageEntity> chatContext,
    List<MemoryItemEntity> memories,
  ) {
    final buffer = StringBuffer();

    // Add relevant memories to context if available
    if (memories.isNotEmpty) {
      buffer.writeln('Relevant knowledge from memory:');
      for (final memory in memories) {
        buffer.writeln('- ${memory.title}: ${memory.content}');
      }
      buffer.writeln();
    }

    // Add recent chat context if available
    if (chatContext.isNotEmpty) {
      buffer.writeln('Previous conversation:');
      // Take last 10 messages for context to avoid token limits
      final recentContext = chatContext.length > 10
          ? chatContext.sublist(chatContext.length - 10)
          : chatContext;

      for (final msg in recentContext) {
        buffer.writeln('${msg.isUser ? 'User' : 'Assistant'}: ${msg.content}');
      }
      buffer.writeln();
    }

    // Add current user message
    buffer.writeln('Current user message: $prompt');
    buffer.writeln();
    buffer.writeln('Please respond considering the knowledge from memory and conversation context above.');

    return buffer.toString();
  }
} 