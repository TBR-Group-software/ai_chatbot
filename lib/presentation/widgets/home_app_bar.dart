import 'package:flutter/material.dart';
import 'package:ai_chat_bot/l10n/l10n.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.points,
  });

  final int points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.chatty,
            style: theme.textTheme.displayLarge,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.star,
                  color: theme.colorScheme.surface,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  points.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
