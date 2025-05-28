import 'package:ai_chat_bot/data/repositories/impl_llm_repository.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/history_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ai_chat_bot/data/services/gemini_service.dart';
import 'package:ai_chat_bot/data/services/hive_storage_service.dart';
import 'package:ai_chat_bot/data/repositories/impl_chat_history_repository.dart';
import 'package:ai_chat_bot/domain/repositories/llm_repository.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history_repository.dart';
import 'package:ai_chat_bot/domain/usecases/generate_text_with_context_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/save_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/delete_chat_session_usecase.dart';

final GetIt sl = GetIt.instance;

void init() {
  // Storage Services
  sl.registerLazySingleton<HiveStorageService>(() => HiveStorageService());

  // API Services
  sl.registerLazySingleton<GeminiService>(() => GeminiService());

  // Repositories
  sl.registerLazySingleton<LLMRepository>(() => ImplLLMRepository(sl.get()));

  sl.registerLazySingleton<ChatHistoryRepository>(
    () => ImplChatHistoryRepository(sl.get()),
  );

  // Use cases
  sl.registerLazySingleton<GenerateTextWithContextUseCase>(
    () => GenerateTextWithContextUseCase(sl.get()),
  );

  sl.registerLazySingleton<SaveChatSessionUseCase>(
    () => SaveChatSessionUseCase(sl.get()),
  );

  sl.registerLazySingleton<GetChatSessionsUseCase>(
    () => GetChatSessionsUseCase(sl.get()),
  );

  sl.registerLazySingleton<GetChatSessionUseCase>(
    () => GetChatSessionUseCase(sl.get()),
  );

  sl.registerLazySingleton<DeleteChatSessionUseCase>(
    () => DeleteChatSessionUseCase(sl.get()),
  );

  // BLoCs
  sl.registerFactory<ChatBloc>(() => ChatBloc(sl.get(), sl.get(), sl.get()));

  sl.registerFactory<HistoryBloc>(
    () => HistoryBloc(sl.get(), sl.get(), sl.get()),
  );

  sl.registerFactory<HomeBloc>(() => HomeBloc(sl.get(), sl.get()));
}
