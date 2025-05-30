// Data layer: Repository implementation
import 'dart:async';
import 'package:ai_chat_bot/data/datasources/remote/gemini/gemini_remote_data_source.dart';
import 'package:ai_chat_bot/data/models/gemini_text_response.dart';
import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/repositories/llm_repository.dart';

/// Implementation of LLM Repository following Clean Architecture
/// Handles data transformation and business logic
class ImplGeminiRepository implements LLMRepository {
  final GeminiRemoteDataSource _remoteDataSource;

  ImplGeminiRepository(this._remoteDataSource);

  @override
  Stream<LLMTextResponseEntity?> generateResponse(String prompt) async* {
    await for (final rawResponse in _remoteDataSource.streamGenerateContent(prompt)) {
      if (rawResponse == null) {
        yield null;
        continue;
      }

      // Handle completion signal
      if (rawResponse['isDone'] == true) {
        yield const LLMTextResponseEntity(text: '', isComplete: true);
        return;
      }

      // Parse and transform raw API response to domain entity
      final geminiResponse = _parseGeminiResponse(rawResponse);
      if (geminiResponse != null && 
          geminiResponse.output != null && 
          geminiResponse.output!.isNotEmpty) {
        final domainResponse = LLMTextResponseEntity.fromGeminiTextResponse(geminiResponse);
        yield domainResponse;
      }
    }
  }

  /// Parses raw Gemini API response to GeminiTextResponse model
  /// This parsing logic belongs in the repository layer as it's data transformation
  GeminiTextResponse? _parseGeminiResponse(Map<String, dynamic> jsonData) {
    try {
      final candidates = jsonData['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return null;
      }

      final candidate = candidates[0] as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;
      
      if (content == null) {
        return null;
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        return null;
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
        return null;
      }

      // Join text parts properly - preserve original formatting from API
      final extractedText = textParts.join('');
      
      // Get finish reason if available
      final finishReason = candidate['finishReason'] as String?;
      final isResponseComplete = finishReason != null;

      return GeminiTextResponse(
        output: extractedText,
        isComplete: isResponseComplete,
        finishReason: finishReason,
      );
    } catch (e) {
      // Return null for malformed responses
      return null;
    }
  }
}
