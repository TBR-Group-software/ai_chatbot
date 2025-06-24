import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'presentation/bloc/memory/memory_bloc_test.dart' as memory_bloc_test;
import 'presentation/bloc/chat/chat_bloc_test.dart' as chat_bloc_test;
import 'presentation/bloc/home/home_bloc_test.dart' as home_bloc_test;
import 'presentation/bloc/history/history_bloc_test.dart' as history_bloc_test;
import 'data/repositories/memory_repository_test.dart' as memory_repository_test;
import 'data/repositories/chat_history_repository_test.dart' as chat_history_repository_test;
import 'data/repositories/gemini_repository_test.dart' as gemini_repository_test;

/// Main test runner that executes all unit tests
/// 
/// This file serves as a comprehensive test suite for the AI Chat Bot application.
/// It includes tests for:
/// - All Bloc state management components
/// - Data layer repositories
/// - Domain layer use cases
/// - Error handling scenarios
/// - Stream subscriptions and real-time updates
/// 
/// To run all tests: flutter test test/all_tests.dart
/// To run with coverage: flutter test --coverage test/all_tests.dart
void main() {
  group('AI Chat Bot - Comprehensive Unit Tests', () {
    group('🧠 Presentation Layer - BLoC Tests', () {
      group('Memory BLoC', memory_bloc_test.main);
      group('Chat BLoC', chat_bloc_test.main);
      group('Home BLoC', home_bloc_test.main);
      group('History BLoC', history_bloc_test.main);
    });

    group('💾 Data Layer - Repository Tests', () {
      group('Memory Repository', memory_repository_test.main);
      group('Chat History Repository', chat_history_repository_test.main);
      group('Gemini Repository', gemini_repository_test.main);
    });
  });
} 
