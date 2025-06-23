import 'package:ai_chat_bot/core/dependency_injection/dependency_injection.dart'
    as di;
import 'package:ai_chat_bot/presentation/bloc/memory/memory_bloc.dart';
import 'package:ai_chat_bot/presentation/popups/chatbot_alert.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/presentation/pages/memory/widgets/memory_item_card.dart';
import 'package:ai_chat_bot/presentation/pages/memory/widgets/add_memory_dialog.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/l10n/l10n.dart';

@RoutePage()
class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage>
    with WidgetsBindingObserver, AutoRouteAware {
  final MemoryBloc _memoryBloc = di.sl.get<MemoryBloc>();
  final TextEditingController _searchController = TextEditingController();
  AutoRouteObserver? _routeObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _memoryBloc.add(LoadMemoryEvent());
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
    _memoryBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh memory when app comes back to foreground
      _refreshMemory();
    }
  }

  void _refreshMemory() {
    _memoryBloc.add(LoadMemoryEvent());
  }

  void _showAddMemoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddMemoryDialog(
            onSave: (item) {
              _memoryBloc.add(AddMemoryEvent(item));
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 128),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(context.l10n.memoryTitle),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          onPressed: _showAddMemoryDialog,
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<MemoryBloc, MemoryState>(
          bloc: _memoryBloc,
          builder: (context, state) {
            return Column(
              children: <Widget>[
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: context.l10n.searchMemoryHint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                    onChanged: (query) {
                      _memoryBloc.add(SearchMemoryEvent(query));
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
                                context.l10n.errorLoadingMemory,
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
                                    () => _memoryBloc.add(LoadMemoryEvent()),
                                child: Text(context.l10n.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state.filteredItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.psychology_outlined,
                                size: 64,
                                color: theme.extension<CustomColors>()!.onSurfaceSubtle,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.searchQuery.isNotEmpty
                                    ? context.l10n.noMemoryItemsFound
                                    : context.l10n.noMemoryItemsYet,
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.searchQuery.isNotEmpty
                                    ? context.l10n.tryDifferentSearchTerm
                                    : context.l10n.addKnowledgePrompt,
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
                          _refreshMemory();
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 128,
                          ),
                          itemCount: state.filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = state.filteredItems[index];
                            return MemoryItemCard(
                              item: item,
                              onEdit: (updatedItem) {
                                _memoryBloc.add(UpdateMemoryEvent(updatedItem));
                              },
                              onDelete:
                                  () => ChatbotAlert.showDeleteConfirmation(
                                    context: context,
                                    title: 'Delete Memory Item',
                                    itemName: item.title,
                                    onConfirm:
                                        () => _memoryBloc.add(
                                          DeleteMemoryEvent(item.id),
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
      ),
    );
  }
}
