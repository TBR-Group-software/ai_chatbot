import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

class ChatInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final FocusNode focusNode;
  final bool isEditing;
  final String? editingHint;
  final VoidCallback? onCancelEdit;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    required this.focusNode,
    this.isEditing = false,
    this.editingHint,
    this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isEditing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.extension<CustomColors>()!.primarySubtle,
              border: Border(
                bottom: BorderSide(
                  color: theme.extension<CustomColors>()!.primaryMuted,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.edit,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    editingHint ?? 'Editing message',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onCancelEdit != null)
                  GestureDetector(
                    onTap: onCancelEdit,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: TextField(
                      onTapOutside: (event) {
                        focusNode.unfocus();
                      },
                      focusNode: focusNode,
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: isEditing ? 'Edit your message...' : 'Message',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: theme.textTheme.bodyLarge,
                      maxLines: null,
                      minLines: 1,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onSend,
                icon: SvgPicture.asset(
                  'assets/images/send_icon.svg',
                  width: 32,
                  height: 32,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
