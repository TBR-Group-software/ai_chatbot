import 'dart:async';
import 'package:ai_chat_bot/data/models/gemini_text_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  final gemini = Gemini.instance;

  Stream<GeminiTextResponse?> generateText(String prompt) {
    final controller = StreamController<GeminiTextResponse?>();

    final subscription = gemini
        .promptStream(
          model: dotenv.env['MODEL_NAME'],
          generationConfig: GenerationConfig(maxOutputTokens: 2048),
          parts: [Part.text(prompt)],
        )
        .listen(
          (candidates) {
            controller.add(GeminiTextResponse.fromCandidate(candidates));
          },
          onError: (error) {
            controller.addError(error);
            controller.close();
          },
          onDone: () {
            controller.close();
          },
        );

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }
}
