import 'package:flutter/material.dart';
import 'package:ai_chat_bot/domain/entities/memory_item_entity.dart';
import 'package:ai_chat_bot/presentation/widgets/date_time_display.dart';
import 'package:ai_chat_bot/presentation/widgets/custom_popup_menu_item.dart';
import 'package:ai_chat_bot/presentation/pages/memory/widgets/edit_memory_dialog.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class MemoryItemCard extends StatelessWidget {

  const MemoryItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });
  final MemoryItemEntity item;
  final Function(MemoryItemEntity) onEdit;
  final VoidCallback onDelete;

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditMemoryDialog(
        item: item,
        onSave: onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditDialog(context);
                        case 'delete':
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => <PopupMenuItem<String>>[
                       CustomPopupMenuItem.edit(context),
                       CustomPopupMenuItem.delete(context),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.extension<CustomColors>()!.primarySubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.extension<CustomColors>()!.primaryMuted,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8),
              DateTimeDisplay(dateTime: item.updatedAt),
            ],
          ),
        ),
      ),
    );
  }
} 
