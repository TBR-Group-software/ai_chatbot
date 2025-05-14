import 'package:ai_chat_bot/core/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../widgets/custom_bottom_nav_bar.dart';

@RoutePage()
class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const <PageRouteInfo<dynamic>>[
        HomeRoute(),
        ExploreRoute(),
        HistoryRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return CustomBottomNavBar(
          selectedIndex: tabsRouter.activeIndex,
          onItemSelected: tabsRouter.setActiveIndex,
        );
      },
    );
  }
}
