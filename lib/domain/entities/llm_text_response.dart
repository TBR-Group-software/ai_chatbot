import 'package:ai_chat_bot/data/models/gemini_text_response.dart';

class LLMTextResponse {
  final String text;
  final bool isComplete;
  final String? finishReason;

  const LLMTextResponse({
    required this.text,
    required this.isComplete,
    this.finishReason,
  });

  factory LLMTextResponse.fromGeminiTextResponse(GeminiTextResponse? response) {
    return LLMTextResponse(
      text: response?.output ?? '',
      isComplete: response?.isComplete ?? false,
      finishReason: response?.finishReason,
    );
  }
}
