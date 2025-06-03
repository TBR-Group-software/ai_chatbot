import 'dart:async';
import '../../../models/gemini/gemini_text_response.dart';

/// Abstract data source for Gemini remote operations
abstract class GeminiRemoteDataSource {
  /// Streams Gemini API responses as typed data models
  Stream<GeminiTextResponse?> streamGenerateContent(String prompt);
}
