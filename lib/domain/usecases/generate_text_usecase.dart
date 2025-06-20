import 'dart:async';

import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/repositories/llm/llm_repository.dart';

/// Use case for generating text responses from LLM.
///
/// Provides simple text generation without any context or memory enhancement.
/// Used for basic AI interactions and simple prompts.
///
/// Uses [LLMRepository] for language model communication.
class GenerateTextUseCase {

  /// Constructor for generate text use case
  ///
  /// [_repository] The LLM repository for text generation operations
  GenerateTextUseCase(this._repository);
  final LLMRepository _repository;

  /// Execute the use case to generate text response
  ///
  /// Generates a response to the provided prompt using the LLM
  /// [prompt] The user prompt to generate a response for
  /// Returns a stream of [LLMTextResponseEntity] updates containing the generated text
  Stream<LLMTextResponseEntity?> call(String prompt) {
    return _repository.generateResponse(prompt);
  }
}
