import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/repositories/impl_gemini_repository.dart';
import 'package:ai_chat_bot/data/datasources/remote/gemini/gemini_remote_datasource.dart';
import 'package:ai_chat_bot/presentation/bloc/chat/chat_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/history/history_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/home/home_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ai_chat_bot/data/datasources/remote/gemini/impl_gemini_remote_datasource.dart';
import 'package:ai_chat_bot/data/datasources/local/hive_storage/imlp_hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/repositories/impl_chat_history_repository.dart';
import 'package:ai_chat_bot/domain/repositories/llm/llm_repository.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';
import 'package:ai_chat_bot/domain/usecases/generate_text_with_context_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/save_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/delete_chat_session_usecase.dart';

final GetIt sl = GetIt.instance;

void init() {
  // Local Data Sources
  sl.registerLazySingleton<HiveStorageLocalDataSource>(() => ImplHiveStorageLocalDataSource());

  // Remote Data Sources
  sl.registerLazySingleton<GeminiRemoteDataSource>(
    () => ImplGeminiRemoteDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<LLMRepository>(
    () => ImplGeminiRepository(sl.get<GeminiRemoteDataSource>()),
  );

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
