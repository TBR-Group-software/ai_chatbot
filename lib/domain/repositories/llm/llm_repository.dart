import 'dart:async';

import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';

abstract class LLMRepository {
  Stream<LLMTextResponseEntity?> generateResponse(String prompt);
}
