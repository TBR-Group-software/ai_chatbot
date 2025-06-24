import 'package:ai_chat_bot/domain/entities/chat_session_entity.dart';
import 'package:ai_chat_bot/presentation/pages/home/widgets/home_history_card.dart';
import 'package:flutter/material.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class HomeHistorySection extends StatelessWidget {
  const HomeHistorySection({
    super.key,
    required this.sessions,
    required this.onSeeAll,
    required this.onSessionTap,
    this.isLoading = false,
  });

  final List<ChatSessionEntity> sessions;
  final VoidCallback onSeeAll;
  final Function(String sessionId) onSessionTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('History', style: theme.textTheme.titleLarge),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 32,
                        color: theme.extension<CustomColors>()!.onSurfaceSubtle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No chat history yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.extension<CustomColors>()!.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: sessions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return HomeHistoryCard(
                    date: _formatDate(session.updatedAt),
                    time: _formatTime(session.updatedAt),
                    title: session.title,
                    onTap: () => onSessionTap(session.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[date.weekday - 1];
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
