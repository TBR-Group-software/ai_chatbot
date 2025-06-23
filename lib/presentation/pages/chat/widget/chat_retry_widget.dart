import 'package:ai_chat_bot/domain/entities/error_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class ChatRetryWidget extends StatelessWidget {

  const ChatRetryWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.isRetrying = false,
  });
  final String errorMessage;
  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo(errorMessage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Error message
        Row(
          children: <Widget>[
            Icon(
              errorInfo.icon,
              size: 16,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorInfo.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Error description
        Text(
          errorInfo.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.extension<CustomColors>()!.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 12),
        
        // Retry button (only show for retryable errors)
        if (errorInfo.canRetry)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isRetrying ? null : onRetry,
              icon: isRetrying
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isRetrying ? 'Retrying...' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
      ],
    );
  }

  ErrorInfoEntity _getErrorInfo(String errorType) {
    switch (errorType) {
      case 'rate_limit':
        return ErrorInfoEntity(
          title: 'Rate limit exceeded',
          description: 'Looks like you have exceeded your limits, please try again later.',
          icon: Icons.schedule_rounded,
          canRetry: false,
        );
      case 'connection_failed':
      default:
        return ErrorInfoEntity(
          title: 'Connection failed',
          description: 'Please check your internet connection and try again.',
          icon: Icons.error_outline_rounded,
          canRetry: true,
        );
    }
  }
}
