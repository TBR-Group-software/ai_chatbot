import 'dart:async';
import 'dart:convert';
import 'package:ai_chat_bot/data/datasources/remote/gemini/gemini_remote_datasource.dart';
import 'package:ai_chat_bot/data/models/gemini/gemini_text_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Implementation of Gemini remote data source
class ImplGeminiRemoteDataSource implements GeminiRemoteDataSource {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com';
  static const String _apiVersion = 'v1beta';

  /// Streams Gemini API responses as typed data models
  /// Handles HTTP communication and converts raw JSON to GeminiTextResponse models
  @override
  Stream<GeminiTextResponse?> streamGenerateContent(String prompt) async* {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final modelName = dotenv.env['MODEL_NAME'] ?? 'gemini-2.0-flash';
    
    if (apiKey == null) {
      throw GeminiRemoteDataSourceException('API_KEY not found in environment variables');
    }

    final url = '$_baseUrl/$_apiVersion/models/$modelName:streamGenerateContent?alt=sse&key=$apiKey';
    
    final requestBody = _buildRequestBody(prompt);

    try {
      final request = _createHttpRequest(url, requestBody);
      final client = http.Client();
      final response = await client.send(request);
      
      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw GeminiRemoteDataSourceException('HTTP ${response.statusCode}: $errorBody');
      }

      yield* _processStreamResponse(response, client);
      
    } catch (e) {
      if (e is GeminiRemoteDataSourceException) {
        rethrow;
      }
      throw GeminiRemoteDataSourceException('Failed to communicate with Gemini API: $e');
    }
  }

  /// Builds the request body for Gemini API
  Map<String, dynamic> _buildRequestBody(String prompt) {
    return {
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
  }

  /// Creates HTTP request with proper headers
  http.Request _createHttpRequest(String url, Map<String, dynamic> body) {
    final request = http.Request('POST', Uri.parse(url));
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';
    request.body = jsonEncode(body);
    return request;
  }

  /// Processes the SSE stream and yields typed GeminiTextResponse models
  /// Converts raw JSON to data models at the datasource level
  Stream<GeminiTextResponse?> _processStreamResponse(
    http.StreamedResponse response,
    http.Client client,
  ) async* {
    String buffer = '';
    
    try {
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
              yield GeminiTextResponse.completed();
              return;
            }
            
            try {
              final jsonData = jsonDecode(data) as Map<String, dynamic>;
              // Convert raw JSON to typed data model at datasource level
              final geminiResponse = GeminiTextResponse.fromJson(jsonData);
              
              // Only yield responses with actual content
              if (geminiResponse.output != null && geminiResponse.output!.isNotEmpty) {
                yield geminiResponse;
              }
            } catch (e) {
              // Skip malformed JSON chunks
              continue;
            }
          }
        }
      }
    } finally {
      client.close();
    }
  }
}

/// Custom exception for Gemini remote data source errors
class GeminiRemoteDataSourceException implements Exception {
  final String message;
  
  const GeminiRemoteDataSourceException(this.message);
  
  @override
  String toString() => 'GeminiRemoteDataSourceException: $message';
} 