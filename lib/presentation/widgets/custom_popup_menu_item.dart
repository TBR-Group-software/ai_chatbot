import 'package:flutter/material.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/l10n/l10n.dart';

class CustomPopupMenuItem extends PopupMenuItem<String> {
  CustomPopupMenuItem._({
    super.key,
    required String value,
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? textColor,
  }) : super(
         value: value,
         child: _MenuItemRow(
           icon: icon,
           label: label,
           iconColor: iconColor,
           textColor: textColor,
         ),
       );

  /// Factory constructor for delete action with red styling
  CustomPopupMenuItem.delete(BuildContext context, {Key? key})
    : this._(
        key: key,
        value: 'delete',
        icon: Icons.delete,
        label: context.l10n.delete,
        iconColor: Colors.red,
        textColor: Colors.red,
      );

  /// Factory constructor for edit action
  CustomPopupMenuItem.edit(BuildContext context, {Key? key})
    : this._(
        key: key,
        value: 'edit',
        icon: Icons.edit,
        label: context.l10n.edit,
      );
}

/// Internal widget for consistent menu item layout
class _MenuItemRow extends StatelessWidget {

  const _MenuItemRow({
    required this.icon,
    required this.label,
    this.iconColor,
    this.textColor,
  });
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Row(
      children: <Widget>[
        Icon(
          icon,
          color:
              iconColor ??
              customColors?.dropdownIcon ??
              theme.colorScheme.onSurface,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color:
                textColor ??
                customColors?.dropdownText ??
                theme.colorScheme.onSurface,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
