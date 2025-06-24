import 'package:flutter/material.dart';

class ChatbotAlert extends StatelessWidget {

  const ChatbotAlert({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = 'Cancel',
    this.onCancel,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.icon,
    this.iconColor,
    this.isDismissible = true,
    this.isDestructive = false,
  });

  /// Factory constructor for delete confirmation dialogs
  factory ChatbotAlert.delete({
    required String title,
    required String itemName,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return ChatbotAlert(
      title: title,
      content: 'Are you sure you want to delete "$itemName"? This action cannot be undone.',
      confirmText: 'Delete',
      onConfirm: onConfirm,
      onCancel: onCancel,
      icon: Icons.warning_amber_rounded,
      isDestructive: true,
    );
  }

  /// Factory constructor for general confirmation dialogs
  factory ChatbotAlert.confirm({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
  }) {
    return ChatbotAlert(
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      icon: icon,
    );
  }

  /// Factory constructor for info dialogs
  factory ChatbotAlert.info({
    required String title,
    required String content,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    return ChatbotAlert(
      title: title,
      content: content,
      confirmText: confirmText,
      onConfirm: onConfirm ?? () {},
      icon: Icons.info_outline,
    );
  }
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final IconData? icon;
  final Color? iconColor;
  final bool isDismissible;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? 
                (isDestructive ? theme.colorScheme.error : theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        if (cancelText.isNotEmpty)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: cancelButtonColor ?? theme.colorScheme.onSurface,
            ),
            child: Text(cancelText),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: confirmButtonColor ?? 
              (isDestructive ? theme.colorScheme.error : theme.colorScheme.primary),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Static method to show the alert dialog
  static Future<void> show({
    required BuildContext context,
    required ChatbotAlert alert,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: alert.isDismissible,
      builder: (context) => alert,
    );
  }

  /// Static method to show delete confirmation
  static Future<void> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String itemName,
    required VoidCallback onConfirm,
  }) {
    return show(
      context: context,
      alert: ChatbotAlert.delete(
        title: title,
        itemName: itemName,
        onConfirm: onConfirm,
      ),
    );
  }

  /// Static method to show general confirmation
  static Future<void> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
  }) {
    return show(
      context: context,
      alert: ChatbotAlert.confirm(
        title: title,
        content: content,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
      ),
    );
  }

  /// Static method to show info dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      alert: ChatbotAlert.info(
        title: title,
        content: content,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }
} 
