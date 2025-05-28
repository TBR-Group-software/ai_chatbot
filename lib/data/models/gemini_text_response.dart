class GeminiTextResponse {
  final String? output;
  final bool isComplete;
  final String? finishReason;

  GeminiTextResponse({this.output, this.isComplete = false, this.finishReason});
}
