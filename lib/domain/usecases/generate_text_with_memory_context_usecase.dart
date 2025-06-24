import 'dart:async';

import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/entities/chat_message_entity.dart';
import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:ai_chat_bot/domain/repositories/llm/llm_repository.dart';
import 'package:ai_chat_bot/domain/usecases/get_relevant_memory_for_context_usecase.dart';

/// Use case for generating text responses with memory-enhanced context
///
/// Provides the most advanced text generation by combining relevant memories
/// with conversation context. Creates highly personalized and contextually
/// aware AI responses based on stored knowledge
///
/// Features:
/// - Intelligent memory retrieval based on prompt relevance
/// - Conversation context integration
/// - Enhanced prompt construction with memory knowledge
/// - Personalized response generation
///
/// Uses [LLMRepository] for language model communication
/// and [GetRelevantMemoryForContextUseCase] for memory retrieval
class GenerateTextWithMemoryContextUseCase {

  /// Constructor for generate text with memory context use case
  ///
  /// [_llmRepository] The LLM repository for text generation operations
  /// [_getRelevantMemoryUseCase] Use case for retrieving relevant memories
  GenerateTextWithMemoryContextUseCase(
    this._llmRepository,
    this._getRelevantMemoryUseCase,
  );
  final LLMRepository _llmRepository;
  final GetRelevantMemoryForContextUseCase _getRelevantMemoryUseCase;

  /// Execute the use case to generate memory-enhanced text response
  ///
  /// Generates AI responses enhanced with both relevant memories and
  /// conversation context for maximum personalization and relevance
  /// [prompt] The current user message
  /// [chatContext] List of previous chat messages for context
  /// Returns a stream of [LLMTextResponseEntity] updates with enhanced response
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

  /// Build an enhanced prompt with memory knowledge and conversation context
  ///
  /// Creates a comprehensive prompt that includes:
  /// - Relevant memories from the knowledge base
  /// - Recent conversation history
  /// - Current user message
  /// [prompt] The current user message
  /// [chatContext] List of previous chat messages
  /// [memories] List of relevant memory items
  /// Returns a formatted prompt with comprehensive context
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
