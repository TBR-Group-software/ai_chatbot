import 'dart:async';
import '../../../models/gemini/gemini_text_response.dart';

/// Abstract data source for Gemini remote operations
/// Returns typed data models instead of raw JSON
abstract class GeminiRemoteDataSource {
  /// Streams Gemini API responses as typed data models
  /// Returns GeminiTextResponse models with proper type safety
  Stream<GeminiTextResponse?> streamGenerateContent(String prompt);
}
