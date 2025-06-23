import 'package:ai_chat_bot/core/router/app_router.gr.dart';
import 'package:auto_route/auto_route.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: NavigationRoute.page,
          initial: true,
          children: [
            AutoRoute(
              page: HomeRoute.page,
              initial: true,
            ),
            AutoRoute(
              page: MemoryRoute.page,
            ),
            AutoRoute(
              page: HistoryRoute.page,
            ),
          ],
        ),
        AutoRoute(
          page: ChatRoute.page,
          path: '/chat',
        ),
      ];
} 
