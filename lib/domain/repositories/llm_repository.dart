import 'dart:async';

import 'package:ai_chat_bot/domain/entities/llm_text_response.dart';

abstract class LLMRepository {
  Stream<LLMTextResponse?> generateResponse(String prompt);
}