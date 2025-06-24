import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;
import 'package:ai_chat_bot/presentation/bloc/history/history_bloc.dart';
import 'package:ai_chat_bot/presentation/popups/chatbot_alert.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/presentation/pages/history/widgets/history_chat_session_card.dart';
import 'package:ai_chat_bot/l10n/l10n.dart';

@RoutePage()
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with WidgetsBindingObserver, AutoRouteAware {
  final HistoryBloc _historyBloc = di.sl.get<HistoryBloc>();
  final TextEditingController _searchController = TextEditingController();
  AutoRouteObserver? _routeObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _historyBloc.add(LoadHistoryEvent());
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
    _searchController.dispose();
    await _historyBloc.close();
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
    _historyBloc.add(LoadHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.chatHistoryTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        bloc: _historyBloc,
        builder: (context, state) {
          return Column(
            children: <Widget>[
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.l10n.searchConversationsHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  onChanged: (query) {
                    _historyBloc.add(SearchSessionsEvent(query));
                  },
                ),
              ),

              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.errorLoadingHistory,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.error!,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed:
                                  () => _historyBloc.add(LoadHistoryEvent()),
                              child: Text(context.l10n.retry),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.filteredSessions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: theme.extension<CustomColors>()!.onSurfaceMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.searchQuery.isNotEmpty
                                  ? context.l10n.noConversationsFound
                                  : context.l10n.noChatHistoryYet,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.searchQuery.isNotEmpty
                                  ? context.l10n.tryDifferentSearchTerm
                                  : context.l10n.startConversationPrompt,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.extension<CustomColors>()!.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _refreshHistory();
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 128,
                        ),
                        itemCount: state.filteredSessions.length,
                        itemBuilder: (context, index) {
                          final session = state.filteredSessions[index];
                          return HistoryChatSessionCard(
                            session: session,
                            onDelete:
                                () async => ChatbotAlert.showDeleteConfirmation(
                                  context: context,
                                  title: context.l10n.deleteConversationTitle,
                                  itemName: session.title,
                                  onConfirm:
                                      () => _historyBloc.add(
                                        DeleteSessionEvent(session.id),
                                      ),
                                ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
