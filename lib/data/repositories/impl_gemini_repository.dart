// Data layer: Repository implementation
import 'dart:async';
import 'package:ai_chat_bot/data/datasources/remote/gemini/gemini_remote_datasource.dart';
import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/repositories/llm/llm_repository.dart';

/// Concrete implementation of [LLMRepository] for Gemini AI
///
/// Acts as a bridge between the domain layer and Gemini data source
/// 
/// Converts data models to domain entities following clean architecture principles
///
/// Uses [GeminiRemoteDataSource] for API communication
class ImplGeminiRepository implements LLMRepository {

  /// Constructor for Gemini repository implementation
  ///
  /// [_remoteDataSource] The Gemini data source for API communication
  ImplGeminiRepository(this._remoteDataSource);
  final GeminiRemoteDataSource _remoteDataSource;

  @override
  Stream<LLMTextResponseEntity?> generateResponse(String prompt) async* {
    await for (final geminiResponse in _remoteDataSource.streamGenerateContent(prompt)) {
      if (geminiResponse == null) {
        yield null;
        continue;
      }

      // Convert data model to domain entity
      final domainEntity = LLMTextResponseEntity.fromGeminiTextResponse(geminiResponse);
      yield domainEntity;
    }
  }
}
