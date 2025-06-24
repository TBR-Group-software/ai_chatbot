import 'package:flutter/material.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ai_chat_bot/l10n/l10n.dart';

class HomeTapToChatCard extends StatelessWidget {
  const HomeTapToChatCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        context.l10n.tapToChat,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.surface,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          wordSpacing: 0,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/tap_to_chat_icon.svg',
                    // width: 32,
                    // height: 32,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SvgPicture.asset(
                      'assets/images/chat_bot_small_logo.svg',
                      width: 32,
                      height: 32,
                    ),
                  ),

                  Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        color: customColors?.almond2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          context.l10n.tapToChatDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
