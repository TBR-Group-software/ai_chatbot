import 'dart:async';

import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/entities/chat_message_entity.dart';
import 'package:ai_chat_bot/domain/repositories/llm/llm_repository.dart';

/// Use case for generating text responses with conversation context
///
/// Enhances LLM responses by including recent conversation history
/// as context. Provides more coherent and contextually aware responses
/// compared to simple text generation
///
/// Features:
/// - Automatic context window management (last 10 messages)
/// - Conversation history formatting
/// - Context-aware prompt construction
///
/// Uses [LLMRepository] for language model communication
class GenerateTextWithContextUseCase {

  /// Constructor for generate text with context use case
  ///
  /// [_llmRepository] The LLM repository for text generation operations
  GenerateTextWithContextUseCase(this._llmRepository);
  final LLMRepository _llmRepository;

  /// Execute the use case to generate contextual text response
  ///
  /// Generates an AI response enhanced with conversation context
  /// [prompt] The current user message
  /// [context] List of previous chat messages for context
  /// Returns a stream of [LLMTextResponseEntity] updates with contextual response
  Stream<LLMTextResponseEntity?> call(String prompt, List<ChatMessageEntity> context) {
    final contextualPrompt = _buildContextualPrompt(prompt, context);
    return _llmRepository.generateResponse(contextualPrompt);
  }

  /// Build a contextual prompt including conversation history
  ///
  /// Constructs a prompt that includes recent conversation context
  /// to help the LLM provide more relevant responses
  /// [prompt] The current user message
  /// [context] List of previous chat messages
  /// Returns a formatted prompt with conversation context
  String _buildContextualPrompt(String prompt, List<ChatMessageEntity> context) {
    if (context.isEmpty) {
      return prompt;
    }

    // Take last 10 messages for context to avoid token limits
    final recentContext = context.length > 10 
        ? context.sublist(context.length - 10) 
        : context;

    final contextString = recentContext.map((msg) => 
      "${msg.isUser ? 'User' : 'Assistant'}: ${msg.content}",
    ).join('\n');

    return '''
Previous conversation:
$contextString

Current user message: $prompt

Please respond considering the conversation context above.''';
  }
} 
