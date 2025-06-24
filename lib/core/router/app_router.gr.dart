// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ai_chat_bot/presentation/pages/chat/chat_page.dart' as _i1;
import 'package:ai_chat_bot/presentation/pages/history/history_page.dart'
    as _i2;
import 'package:ai_chat_bot/presentation/pages/home/home_page.dart' as _i3;
import 'package:ai_chat_bot/presentation/pages/memory/memory_page.dart' as _i4;
import 'package:ai_chat_bot/presentation/pages/navigation/navigation_page.dart'
    as _i5;
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

/// generated route for
/// [_i1.ChatPage]
class ChatRoute extends _i6.PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    _i7.Key? key,
    String? sessionId,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         ChatRoute.name,
         args: ChatRouteArgs(key: key, sessionId: sessionId),
         initialChildren: children,
       );

  static const String name = 'ChatRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRouteArgs>(
        orElse: () => const ChatRouteArgs(),
      );
      return _i1.ChatPage(key: args.key, sessionId: args.sessionId);
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({this.key, this.sessionId});

  final _i7.Key? key;

  final String? sessionId;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, sessionId: $sessionId}';
  }
}

/// generated route for
/// [_i2.HistoryPage]
class HistoryRoute extends _i6.PageRouteInfo<void> {
  const HistoryRoute({List<_i6.PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.HistoryPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i6.PageRouteInfo<void> {
  const HomeRoute({List<_i6.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.MemoryPage]
class MemoryRoute extends _i6.PageRouteInfo<void> {
  const MemoryRoute({List<_i6.PageRouteInfo>? children})
    : super(MemoryRoute.name, initialChildren: children);

  static const String name = 'MemoryRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.MemoryPage();
    },
  );
}

/// generated route for
/// [_i5.NavigationPage]
class NavigationRoute extends _i6.PageRouteInfo<void> {
  const NavigationRoute({List<_i6.PageRouteInfo>? children})
    : super(NavigationRoute.name, initialChildren: children);

  static const String name = 'NavigationRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.NavigationPage();
    },
  );
}
