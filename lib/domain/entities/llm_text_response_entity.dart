import 'package:ai_chat_bot/data/models/gemini/gemini_text_response.dart';

/// Domain entity for LLM text response
/// Represents the business logic view of text generation responses
class LLMTextResponseEntity {

  const LLMTextResponseEntity({
    required this.text,
    required this.isComplete,
    this.finishReason,
  });

  /// Factory constructor to convert from data model to domain entity
  factory LLMTextResponseEntity.fromGeminiTextResponse(
    GeminiTextResponse response,
  ) {
    return LLMTextResponseEntity(
      text: response.output ?? '',
      isComplete: response.isComplete,
      finishReason: response.finishReason,
    );
  }

  /// Factory constructor for completed response
  factory LLMTextResponseEntity.completed() {
    return const LLMTextResponseEntity(text: '', isComplete: true);
  }

  /// Factory constructor for empty response
  factory LLMTextResponseEntity.empty() {
    return const LLMTextResponseEntity(text: '', isComplete: false);
  }
  final String text;
  final bool isComplete;
  final String? finishReason;

  @override
  String toString() {
    return 'LLMTextResponseEntity(text: $text, isComplete: $isComplete, finishReason: $finishReason)';
  }
}
