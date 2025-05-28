import 'dart:async';
import 'dart:convert';
import 'package:ai_chat_bot/data/models/gemini_text_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com';
  static const String _apiVersion = 'v1beta';

  Stream<GeminiTextResponse?> generateText(String prompt) {
    return _streamGenerateContent(prompt);
  }

  Stream<GeminiTextResponse?> _streamGenerateContent(String prompt) async* {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final modelName = dotenv.env['MODEL_NAME'] ?? 'gemini-2.0-flash';
    
    if (apiKey == null) {
      throw Exception('API_KEY not found in environment variables');
    }

    final url = '$_baseUrl/$_apiVersion/models/$modelName:streamGenerateContent?alt=sse&key=$apiKey';
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'maxOutputTokens': 2048,
        'temperature': 0.7,
      }
    };

    try {
      final request = http.Request('POST', Uri.parse(url));
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';
      request.body = jsonEncode(requestBody);

      final client = http.Client();
      final response = await client.send(request);
      
      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw Exception('HTTP ${response.statusCode}: $errorBody');
      }

      String buffer = '';
      
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        
        // Process complete lines
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete line in buffer
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          
          // Parse SSE format
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            
            if (data == '[DONE]') {
              yield GeminiTextResponse(output: '', isComplete: true);
              client.close();
              return;
            }
            
            try {
              final jsonData = jsonDecode(data);
              final geminiResponse = _parseStreamResponse(jsonData);
              if (geminiResponse != null && geminiResponse.output != null && geminiResponse.output!.isNotEmpty) {
                yield geminiResponse;
              }
            } catch (e) {
              // Skip malformed JSON chunks
              continue;
            }
          }
        }
      }
      
      // Yield final response indicating completion
      yield GeminiTextResponse(output: '', isComplete: true);
      client.close();
      
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }

  GeminiTextResponse? _parseStreamResponse(Map<String, dynamic> jsonData) {
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