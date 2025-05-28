import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/presentation/widgets/home_app_bar.dart';
import 'package:ai_chat_bot/presentation/widgets/chat_input_card.dart';
import 'package:ai_chat_bot/presentation/widgets/history_section.dart';
import 'package:ai_chat_bot/presentation/widgets/category_section.dart';
import 'package:ai_chat_bot/presentation/bloc/home_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/home_event.dart';
import 'package:ai_chat_bot/presentation/bloc/home_state.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/core/router/app_router.gr.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final HomeBloc _homeBloc = di.sl.get<HomeBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeBloc.add(LoadRecentHistoryEvent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh history when app comes back to foreground
      _refreshHistory();
    }
  }

  void _refreshHistory() {
    _homeBloc.add(RefreshRecentHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshHistory();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: const HomeAppBar(points: 20),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChatInputCard(
                    onTap: () {
                      context.router.push(ChatRoute()).then((_) {
                        // Refresh history when returning from chat
                        _refreshHistory();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: BlocBuilder<HomeBloc, HomeState>(
                    bloc: _homeBloc,
                    builder: (context, state) {
                      if (state.recentSessions.isNotEmpty) {
                        return HistorySection(
                          sessions: state.recentSessions,
                          isLoading: state.isLoading,
                          onSeeAll: () {
                            context.router.navigate(
                              const NavigationRoute(children: [HistoryRoute()]),
                            );
                          },
                          onSessionTap: (sessionId) {
                            // Navigate to chat page with session loaded
                            context.router
                                .push(ChatRoute(sessionId: sessionId))
                                .then((_) {
                                  // Refresh history when returning from chat
                                  _refreshHistory();
                                });
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CategorySection(
                    items: [
                      CategoryItemData(
                        title: 'Story',
                        description: 'Generate a story from a given subject.',
                        icon: Icons.book,
                        iconColor: customColors?.aquamarine ?? Colors.white,
                        onTap: () {},
                      ),
                      CategoryItemData(
                        title: 'Lyrics',
                        description:
                            'Generate lyrics of a song for any music genre.',
                        icon: Icons.music_note,
                        iconColor: customColors?.lightBlue ?? Colors.white,
                        onTap: () {},
                      ),
                      CategoryItemData(
                        title: 'Write code',
                        description:
                            'Write applications in various programming languages.',
                        icon: Icons.code,
                        iconColor: customColors?.lightGray ?? Colors.white,
                        onTap: () {},
                      ),
                      CategoryItemData(
                        title: 'Recipe',
                        description: 'Get recipes for any food dishes.',
                        icon: Icons.restaurant_menu,
                        iconColor: customColors?.orange ?? Colors.white,
                        onTap: () {},
                      ),
                    ],
                    onSeeAll: () {},
                  ),
                ),
                const SizedBox(height: 128),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
