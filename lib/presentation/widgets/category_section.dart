import 'package:flutter/material.dart';
import 'package:ai_chat_bot/presentation/widgets/category_card.dart';
import 'package:ai_chat_bot/l10n/l10n.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.items,
    required this.onSeeAll,
  });

  final List<CategoryItemData> items;
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
            children: [
              Text(context.l10n.popularCategory, style: theme.textTheme.titleLarge),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  context.l10n.seeAll,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return CategoryCard(
              title: item.title,
              description: item.description,
              icon: item.icon,
              iconColor: item.iconColor,
              onTap: item.onTap,
            );
          },
        ),
      ],
    );
  }
}

class CategoryItemData {
  const CategoryItemData({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.iconColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
}
