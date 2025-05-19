import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiTextResponse {
  final String? output;
  final bool isComplete;
  final String? finishReason;

  GeminiTextResponse({this.output, this.isComplete = false, this.finishReason});

  factory GeminiTextResponse.fromCandidate(Candidates? candidate) {
    return GeminiTextResponse(
      output: candidate?.output,
      isComplete: candidate?.finishReason != null,
      finishReason: candidate?.finishReason,
    );
  }
}
