/// Data model for Gemini API text response
/// Represents the structure of data returned from Gemini API
class GeminiTextResponse {

  const GeminiTextResponse({
    this.output,
    this.isComplete = false,
    this.finishReason,
  });

  /// Factory constructor to create GeminiTextResponse from raw API JSON
  factory GeminiTextResponse.fromJson(Map<String, dynamic> json) {
    try {
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return const GeminiTextResponse();
      }

      final candidate = candidates[0] as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;

      if (content == null) {
        return const GeminiTextResponse();
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        return const GeminiTextResponse();
      }

      // Extract text from parts and properly handle spacing
      final textParts = <String>[];
      for (final part in parts) {
        if (part is Map<String, dynamic> && part.containsKey('text')) {
          final text = part['text'] as String?;
          if (text != null && text.isNotEmpty) {
            textParts.add(text);
          }
        }
      }

      if (textParts.isEmpty) {
        return const GeminiTextResponse();
      }

      // Join text parts properly - preserve original formatting from API
      final extractedText = textParts.join();

      // Get finish reason if available
      final finishReason = candidate['finishReason'] as String?;
      final isResponseComplete = finishReason != null;

      return GeminiTextResponse(
        output: extractedText,
        isComplete: isResponseComplete,
        finishReason: finishReason,
      );
    } catch (e) {
      // Return empty response for malformed JSON
      return const GeminiTextResponse();
    }
  }

  /// Factory constructor for completion signal
  factory GeminiTextResponse.completed() {
    return const GeminiTextResponse(output: '', isComplete: true);
  }

  /// Factory constructor for empty response
  factory GeminiTextResponse.empty() {
    return const GeminiTextResponse();
  }
  final String? output;
  final bool isComplete;
  final String? finishReason;

  @override
  String toString() {
    return 'GeminiTextResponse(output: $output, isComplete: $isComplete, finishReason: $finishReason)';
  }
}
