import 'package:ai_chat_bot/presentation/pages/home/widgets/home_tap_to_chat_card.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/presentation/widgets/home_app_bar.dart';
import 'package:ai_chat_bot/presentation/pages/home/widgets/home_history_section.dart';
import 'package:ai_chat_bot/presentation/widgets/category_section.dart';
import 'package:ai_chat_bot/presentation/bloc/home/home_bloc.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/core/router/app_router.gr.dart';
import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;
import 'package:ai_chat_bot/l10n/l10n.dart';

/// The main home page of the AI Chatbot application.
///
/// This page serves as the primary entry point and dashboard for users,
/// providing quick access to chat functionality, recent conversation history,
/// and feature categories. It implements a modern, scrollable interface with
/// pull-to-refresh capabilities and intelligent lifecycle management.
///
/// The home page integrates multiple sophisticated features:
/// * **Quick Chat Access**: Prominent "Tap to Chat" card for immediate conversation start
/// * **Recent History**: Dynamic display of recent chat sessions with navigation
/// * **Feature Categories**: Organized categories for different AI capabilities
/// * **Pull-to-Refresh**: Intuitive refresh functionality for updated content
/// * **Lifecycle Awareness**: Automatic data refresh on app resume and navigation
/// * **Route Integration**: Seamless navigation with the app's routing system
///
/// Architecture features:
/// * **BLoC Integration**: Uses [HomeBloc] for state management and data loading
/// * **Dependency Injection**: Leverages service locator for clean architecture
/// * **Route Observation**: Implements [AutoRouteAware] for navigation lifecycle
/// * **App Lifecycle**: Observes app state changes with [WidgetsBindingObserver]
/// * **Memory Management**: Proper resource cleanup and disposal
///
/// Layout structure:
/// * **App Bar**: Custom home app bar with user information and points
/// * **Chat Card**: Prominent call-to-action for starting new conversations
/// * **History Section**: Conditionally displayed recent conversation history
/// * **Categories**: Feature discovery section with various AI capabilities
/// * **Safe Areas**: Proper padding and safe area handling for all devices
///
/// Example usage (managed by routing):
/// ```dart
/// // Automatically managed by auto_route
/// @RoutePage()
/// class HomePage extends StatefulWidget {
///   const HomePage({super.key});
/// }
///
/// // Navigation to home page
/// context.router.navigate(const NavigationRoute(
///   children: [HomeRoute()],
/// ));
///
/// // Direct access (not recommended, use routing)
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (context) => const HomePage()),
/// );
/// ```
///
/// Performance optimizations:
/// * **Conditional Rendering**: History section only renders when data exists
/// * **Efficient Refresh**: Smart refresh logic prevents unnecessary API calls
/// * **Memory Management**: Proper disposal of BLoC and observers
/// * **Lazy Loading**: Components load data only when needed
@RoutePage()
class HomePage extends StatefulWidget {
  /// Creates the main home page widget.
  ///
  /// This widget serves as the application's dashboard and primary
  /// navigation hub. It requires no parameters as all dependencies
  /// are managed through dependency injection.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Private state class for [HomePage] that manages lifecycle and navigation awareness.
///
/// This state class implements multiple mixins to provide comprehensive
/// lifecycle management:
/// * [WidgetsBindingObserver] for app lifecycle awareness
/// * [AutoRouteAware] for navigation lifecycle tracking
///
/// The state manages automatic data refresh scenarios and ensures the
/// home page content stays current with the latest information.
class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, AutoRouteAware {
  final HomeBloc _homeBloc = di.sl.get<HomeBloc>();
  AutoRouteObserver? _routeObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeBloc.add(LoadRecentHistoryEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver =
        RouterScope.of(context).firstObserverOfType<AutoRouteObserver>();
    if (_routeObserver != null) {
      _routeObserver!.subscribe(this, context.routeData);
    }
  }

  @override
  Future<void> dispose() async {
    _routeObserver?.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    await _homeBloc.close();
    super.dispose();
  }

  /// Handles app lifecycle state changes for intelligent data refresh.
  ///
  /// Automatically refreshes the home page content when the app returns
  /// to the foreground, ensuring users always see the most current
  /// information when they return to the app.
  ///
  /// This is particularly useful for:
  /// * Updating recent chat history after external changes
  /// * Refreshing data after the app was backgrounded
  /// * Ensuring consistency when returning from other apps
  ///
  /// [state] The new app lifecycle state
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh history when app comes back to foreground
      _refreshHistory();
    }
  }

  /// Handles initial tab route initialization.
  ///
  /// Called when this tab route is initialized for the first time
  /// in a tab-based navigation system. Ensures the home page has
  /// fresh data when first displayed.
  ///
  /// [previousRoute] The previous tab route (may be null)
  @override
  void didInitTabRoute(TabPageRoute? previousRoute) {
    // Called when this tab route is initialized for the first time
    _refreshHistory();
  }

  /// Handles tab route changes when switching to the home tab.
  ///
  /// Called when the user switches to the home tab from another tab.
  /// Refreshes the content to ensure users see current information
  /// when navigating between tabs.
  ///
  /// [previousRoute] The tab route the user switched from
  @override
  void didChangeTabRoute(TabPageRoute previousRoute) {
    // Called when switching to this tab from another tab
    _refreshHistory();
  }

  /// Handles navigation returns to the home page.
  ///
  /// Called when returning to the home page from another route
  /// (e.g., coming back from a chat session). Refreshes the content
  /// to reflect any changes that may have occurred during navigation.
  @override
  void didPopNext() {
    // Called when returning to this route from another route
    _refreshHistory();
  }

  /// Refreshes the recent chat history data.
  ///
  /// This method triggers a refresh of the recent conversation history
  /// through the [HomeBloc]. It's called in various lifecycle scenarios
  /// to ensure the displayed data remains current.
  ///
  /// The refresh is intelligent and only updates when necessary,
  /// preventing unnecessary network requests or data processing.
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
          minimum: const EdgeInsets.only(bottom: 128),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 24),
                  child: HomeAppBar(points: 20),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HomeTapToChatCard(
                    onTap: () async {
                      await context.router.push(ChatRoute()).then((_) {
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
                        return HomeHistorySection(
                          sessions: state.recentSessions,
                          isLoading: state.isLoading,
                          onSeeAll: () async {
                            await context.router.navigate(
                              const NavigationRoute(children: [HistoryRoute()]),
                            );
                          },
                          onSessionTap: (sessionId) async {
                            // Navigate to chat page with session loaded
                            await context.router
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
                  padding: const EdgeInsets.only(top: 12, bottom: 64),
                  child: CategorySection(
                    items: <CategoryItemData>[
                      CategoryItemData(
                        title: context.l10n.storyTitle,
                        description: context.l10n.storyDescription,
                        icon: Icons.book,
                        iconColor: customColors?.aquamarine ?? Colors.white,
                        onTap: () {},
                      ),
                      CategoryItemData(
                        title: context.l10n.lyricsTitle,
                        description: context.l10n.lyricsDescription,
                        icon: Icons.music_note,
                        iconColor: customColors?.lightBlue ?? Colors.white,
                        onTap: () {},
                      ),
                      CategoryItemData(
                        title: context.l10n.writeCodeTitle,
                        description: context.l10n.writeCodeDescription,
                        icon: Icons.code,
                        iconColor: customColors?.lightGray ?? Colors.white,
                        onTap: () {},
                      ),
                      CategoryItemData(
                        title: context.l10n.recipeTitle,
                        description: context.l10n.recipeDescription,
                        icon: Icons.restaurant_menu,
                        iconColor: customColors?.orange ?? Colors.white,
                        onTap: () {},
                      ),
                    ],
                    onSeeAll: () {},
                  ),
                ),
                // const SizedBox(height: 128),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
