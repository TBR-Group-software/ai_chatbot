import 'package:flutter/material.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class DateTimeDisplay extends StatelessWidget {

  const DateTimeDisplay({
    super.key,
    required this.dateTime,
    this.style,
  });
  final DateTime dateTime;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: <Widget>[
        Icon(
          Icons.access_time,
          size: 14,
          color: theme.extension<CustomColors>()!.onSurfaceDim,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(dateTime),
          style: style ?? theme.textTheme.bodySmall?.copyWith(
            color: theme.extension<CustomColors>()!.onSurfaceDim,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
} 
