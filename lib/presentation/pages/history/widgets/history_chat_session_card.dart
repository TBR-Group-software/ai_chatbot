import 'package:ai_chat_bot/core/router/app_router.gr.dart';
import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ai_chat_bot/presentation/widgets/date_time_display.dart';
import 'package:ai_chat_bot/presentation/widgets/custom_popup_menu_item.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class HistoryChatSessionCard extends StatelessWidget {
  const HistoryChatSessionCard({super.key, required this.session, required this.onDelete});
  final ChatSessionEntity session;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sessionTitle = _getSessionTitle(session);
    final sessionUpdatedAt = _getSessionUpdatedAt(session);
    final sessionId = _getSessionId(session);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(sessionTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getLastMessage(session),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.extension<CustomColors>()!.onSurfaceMuted),
            ),
            const SizedBox(height: 4),
            DateTimeDisplay(dateTime: sessionUpdatedAt),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: theme.extension<CustomColors>()!.primarySubtle,
          child: Icon(Icons.chat, color: theme.colorScheme.primary),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [CustomPopupMenuItem.delete(context)],
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
        ),
        onTap: () => context.router.push(ChatRoute(sessionId: sessionId)),
      ),
    );
  }

  String _getSessionTitle(ChatSessionEntity session) {
    try {
      return session.title;
    } catch (e) {
      return 'Untitled Session';
    }
  }

  DateTime _getSessionUpdatedAt(ChatSessionEntity session) {
    try {
      final updatedAt = session.updatedAt;
      return updatedAt;
    } catch (e) {
      return DateTime.now();
    }
  }

  String _getSessionId(ChatSessionEntity session) {
    try {
      return (session.id as String?) ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getLastMessage(ChatSessionEntity session) {
    try {
      final messages = session.messages;
      if (messages.isEmpty) {
        return 'No messages';
      }
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        final content = lastMessage.content;
        return (content as String?) ?? 'No content';
      }
      return 'No messages';
    } catch (e) {
      return 'No messages';
    }
  }
}
