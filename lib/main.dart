import 'package:ai_chat_bot/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart' as di;
import 'package:ai_chat_bot/data/datasources/local/hive_storage/imlp_hive_storage_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive Storage
  final hiveStorage = ImplHiveStorageLocalDataSource();
  await hiveStorage.init();

  // Initialize dependency injection
  di.init();

  // Initialize environment variables
  await dotenv.load();

  runApp(ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  ChatBotApp({super.key});

  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(
        navigatorObservers: () => [AutoRouteObserver()],
      ),
      title: 'AI Chat Bot',
      theme: AppTheme.darkTheme,
    );
  }
}
