import 'dart:async';

import '../entities/llm_text_response.dart';
import '../entities/chat_message.dart';
import '../repositories/llm_repository.dart';

class GenerateTextWithContextUseCase {
  final LLMRepository _llmRepository;

  GenerateTextWithContextUseCase(this._llmRepository);

  Stream<LLMTextResponse?> call(String prompt, List<ChatMessage> context) {
    final contextualPrompt = _buildContextualPrompt(prompt, context);
    return _llmRepository.generateResponse(contextualPrompt);
  }

  String _buildContextualPrompt(String prompt, List<ChatMessage> context) {
    if (context.isEmpty) {
      return prompt;
    }

    // Take last 10 messages for context to avoid token limits
    final recentContext = context.length > 10 
        ? context.sublist(context.length - 10) 
        : context;

    final contextString = recentContext.map((msg) => 
      "${msg.isUser ? 'User' : 'Assistant'}: ${msg.content}"
    ).join('\n');

    return """Previous conversation:
$contextString

Current user message: $prompt

Please respond considering the conversation context above.""";
  }
} 