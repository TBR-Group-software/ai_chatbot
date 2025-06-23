import 'dart:async';
import 'package:ai_chat_bot/data/models/gemini/gemini_text_response.dart';

/// Abstract data source for Gemini remote operations
///
/// Provides access to Google's Gemini AI API for text generation
///
/// Uses streaming responses to handle real-time text generation
/// and converts raw API responses to typed [GeminiTextResponse] models
abstract class GeminiRemoteDataSource {
  /// Streams Gemini API responses as typed data models
  ///
  /// [prompt] The text prompt to send to Gemini API
  /// Returns a stream of [GeminiTextResponse] objects containing the generated text
  /// May yield null values during streaming process
  Stream<GeminiTextResponse?> streamGenerateContent(String prompt);
}
