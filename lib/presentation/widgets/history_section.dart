import 'package:flutter/material.dart';
import 'package:ai_chat_bot/presentation/widgets/history_item.dart';

class HistorySection extends StatelessWidget {
  const HistorySection({
    super.key,
    required this.items,
    required this.onSeeAll,
  });

  final List<HistoryItemData> items;
  final VoidCallback onSeeAll;

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
              Text(
                'History',
                style: theme.textTheme.titleLarge,
              ),
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
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return HistoryItem(
                date: item.date,
                time: item.time,
                title: item.title,
                onTap: item.onTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

class HistoryItemData {
  const HistoryItemData({
    required this.date,
    required this.time,
    required this.title,
    required this.onTap,
  });

  final String date;
  final String time;
  final String title;
  final VoidCallback onTap;
} 