import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

class ChatHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const ChatHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.router.pop(),
      ),
      title: const Text('Chat'),
      actions: <Widget>[
        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
