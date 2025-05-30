import 'dart:async';

import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/repositories/llm/llm_repository.dart';

class GenerateTextUseCase {
  final LLMRepository _repository;

  GenerateTextUseCase(this._repository);

  Stream<LLMTextResponseEntity?> call(String prompt) {
    return _repository.generateResponse(prompt);
  }
}
