import 'package:ai_chat_bot/data/models/gemini_text_response.dart';

class LLMTextResponseEntity {
  final String text;
  final bool isComplete;
  final String? finishReason;

  const LLMTextResponseEntity({
    required this.text,
    required this.isComplete,
    this.finishReason,
  });

  factory LLMTextResponseEntity.fromGeminiTextResponse(GeminiTextResponse? response) {
    return LLMTextResponseEntity(
      text: response?.output ?? '',
      isComplete: response?.isComplete ?? false,
      finishReason: response?.finishReason,
    );
  }
}
