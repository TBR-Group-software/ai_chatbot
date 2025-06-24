import 'package:ai_chat_bot/core/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ai_chat_bot/presentation/widgets/custom_bottom_nav_bar.dart';

@RoutePage()
class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AutoTabsRouter(
        routes: const <PageRouteInfo<dynamic>>[
          HomeRoute(),
          MemoryRoute(),
          HistoryRoute(),
        ],
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);
          return Stack(
            children: <Widget>[
              child,
              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: CustomBottomNavBar(
                  selectedIndex: tabsRouter.activeIndex,
                  onItemSelected: tabsRouter.setActiveIndex,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
