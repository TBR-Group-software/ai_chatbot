import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/main_page.dart';

void main() {
  runApp(const ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  const ChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat Bot',
      theme: AppTheme.darkTheme,
      home: const MainPage(),
    );
  }
}
