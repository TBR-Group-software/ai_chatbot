import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ai_chat_bot/presentation/widgets/chat_header.dart';
import 'package:ai_chat_bot/presentation/widgets/chat_input_card.dart';
import 'package:ai_chat_bot/presentation/widgets/history_section.dart';
import 'package:ai_chat_bot/presentation/widgets/category_section.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const ChatHeader(points: 20),
              const SizedBox(height: 24),
              ChatInputCard(
                onTap: () {
                  // TODO: Implement chat input tap
                },
              ),
              const SizedBox(height: 24),
              HistorySection(
                items: [
                  HistoryItemData(
                    date: 'Saturday, 16 Dec 2023',
                    time: '12:16',
                    title: 'What is a programming...',
                    onTap: () {
                      // TODO: Implement history item tap
                    },
                  ),
                  HistoryItemData(
                    date: 'Friday, 15 Dec 2023',
                    time: '20:48',
                    title: 'How long will it take me to lean...',
                    onTap: () {
                      // TODO: Implement history item tap
                    },
                  ),
                ],
                onSeeAll: () {
                  // TODO: Implement see all history
                },
              ),
              const SizedBox(height: 24),
              CategorySection(
                items: [
                  CategoryItemData(
                    title: 'Story',
                    description: 'Generate a story from a given subject.',
                    icon: Icons.book,
                    iconColor: customColors?.aquamarine ?? Colors.white,
                    onTap: () {
                      // TODO: Implement category tap
                    },
                  ),
                  CategoryItemData(
                    title: 'Lyrics',
                    description:
                        'Generate lyrics of a song for any music genre.',
                    icon: Icons.music_note,
                    iconColor: customColors?.lightBlue ?? Colors.white,
                    onTap: () {
                      // TODO: Implement category tap
                    },
                  ),
                  CategoryItemData(
                    title: 'Write code',
                    description:
                        'Write applications in various programming languages.',
                    icon: Icons.code,
                    iconColor: customColors?.lightGray ?? Colors.white,
                    onTap: () {
                      // TODO: Implement category tap
                    },
                  ),
                  CategoryItemData(
                    title: 'Recipe',
                    description: 'Get recipes for any food dishes.',
                    icon: Icons.restaurant_menu,
                    iconColor: customColors?.orange ?? Colors.white,
                    onTap: () {
                      // TODO: Implement category tap
                    },
                  ),
                ],
                onSeeAll: () {
                  // TODO: Implement see all categories
                },
              ),
              const SizedBox(height: 128),
            ],
          ),
        ),
      ),
    );
  }
}
