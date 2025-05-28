import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../core/dependency_injection/dependency_injection.dart' as di;
import '../../core/router/app_router.gr.dart';

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
  void dispose() {
    _routeObserver?.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _historyBloc.close();
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
        title: const Text('Chat History'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        bloc: _historyBloc,
        builder: (context, state) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
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
                              'Error loading history',
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
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.filteredSessions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.searchQuery.isNotEmpty
                                  ? 'No conversations found'
                                  : 'No chat history yet',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.searchQuery.isNotEmpty
                                  ? 'Try a different search term'
                                  : 'Start a conversation to see it here',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.filteredSessions.length,
                        itemBuilder: (context, index) {
                          final session = state.filteredSessions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                session.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    _getLastMessage(session),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(session.updatedAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.chat,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: theme.colorScheme.error,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _showDeleteConfirmation(
                                      context,
                                      session.id,
                                      session.title,
                                    );
                                  }
                                },
                              ),
                              onTap:
                                  () => context.router.push(
                                    ChatRoute(sessionId: session.id),
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

  String _getLastMessage(session) {
    if (session.messages.isEmpty) return 'No messages';
    final lastMessage = session.messages.last;
    return lastMessage.content;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String sessionId,
    String title,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: Text(
              'Are you sure you want to delete "$title"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _historyBloc.add(DeleteSessionEvent(sessionId));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
