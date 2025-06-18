// Data layer: Repository implementation
import 'dart:async';
import 'package:ai_chat_bot/data/datasources/remote/gemini/gemini_remote_datasource.dart';
import 'package:ai_chat_bot/domain/entities/llm_text_response_entity.dart';
import 'package:ai_chat_bot/domain/repositories/llm/llm_repository.dart';

class ImplGeminiRepository implements LLMRepository {
  final GeminiRemoteDataSource _remoteDataSource;

  ImplGeminiRepository(this._remoteDataSource);

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
