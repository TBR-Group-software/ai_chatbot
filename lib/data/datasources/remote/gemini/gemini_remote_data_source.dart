import 'dart:async';

/// Abstract data source for LLM remote operations
/// Follows Dependency Inversion Principle
abstract class GeminiRemoteDataSource {
  /// Streams raw API responses for text generation
  Stream<Map<String, dynamic>?> streamGenerateContent(String prompt);
}
