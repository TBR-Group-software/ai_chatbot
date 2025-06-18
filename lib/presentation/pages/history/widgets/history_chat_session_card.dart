import 'package:ai_chat_bot/core/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../widgets/date_time_display.dart';
import '../../../widgets/custom_popup_menu_item.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class HistoryChatSessionCard extends StatelessWidget {
  final dynamic session;
  final VoidCallback onDelete;

  const HistoryChatSessionCard({
    super.key,
    required this.session,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                color: theme.extension<CustomColors>()!.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 4),
            DateTimeDisplay(dateTime: session.updatedAt),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: theme.extension<CustomColors>()!.primarySubtle,
          child: Icon(
            Icons.chat,
            color: theme.colorScheme.primary,
          ),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
             CustomPopupMenuItem.delete(),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
        ),
        onTap: () => context.router.push(
          ChatRoute(sessionId: session.id),
        ),
      ),
    );
  }

  String _getLastMessage(dynamic session) {
    if (session.messages.isEmpty) return 'No messages';
    final lastMessage = session.messages.last;
    return lastMessage.content;
  }
} 