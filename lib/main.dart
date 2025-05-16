import 'package:ai_chat_bot/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'core/theme/app_theme.dart';
import 'core/dependency_injection/dependency_injection.dart' as di;

void main() async {
  di.init();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Gemini.init(
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    disableAutoUpdateModelName: true,
  );
  runApp(ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  ChatBotApp({super.key});

  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(),
      title: 'AI Chat Bot',
      theme: AppTheme.darkTheme,
    );
  }
}
