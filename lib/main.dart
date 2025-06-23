import 'package:ai_chat_bot/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart' as di;
import 'package:ai_chat_bot/data/datasources/local/hive_storage/imlp_hive_storage_local_datasource.dart';
import 'core/theme/app_theme.dart';
import 'core/dependency_injection/dependency_injection.dart' as di;
import 'data/datasources/local/hive_storage/imlp_hive_storage_local_datasource.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';

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
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
