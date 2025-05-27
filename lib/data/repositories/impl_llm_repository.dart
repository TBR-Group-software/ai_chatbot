// Data layer: Repository implementation
import 'dart:async';
import 'package:ai_chat_bot/data/services/gemini_service.dart';
import 'package:ai_chat_bot/domain/entities/llm_text_response.dart';
import 'package:ai_chat_bot/domain/repositories/llm_repository.dart';

class ImplLLMRepository implements LLMRepository {
  final GeminiService _service;

  ImplLLMRepository(this._service);

  @override
  Stream<LLMTextResponse?> generateResponse(String prompt) async* {
    await for (final response in _service.generateText(prompt)) {
      if (response != null &&
          response.output != null &&
          response.output!.isNotEmpty) {
        final textResponse = LLMTextResponse.fromGeminiTextResponse(response);
        yield textResponse;
      } else {
        yield null;
      }
    }
  }
}
