import 'package:ai_chat_bot/data/datasources/local/hive_storage/hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/repositories/impl_gemini_repository.dart';
import 'package:ai_chat_bot/data/datasources/remote/gemini/gemini_remote_datasource.dart';
import 'package:ai_chat_bot/presentation/bloc/chat/chat_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/history/history_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/home/home_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/memory/memory_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/voice_recording/voice_recording_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ai_chat_bot/data/datasources/remote/gemini/impl_gemini_remote_datasource.dart';
import 'package:ai_chat_bot/data/datasources/local/hive_storage/imlp_hive_storage_local_datasource.dart';
import 'package:ai_chat_bot/data/repositories/impl_chat_history_repository.dart';
import 'package:ai_chat_bot/data/repositories/impl_memory_repository.dart';
import 'package:ai_chat_bot/data/repositories/voice_recording_repository_impl.dart';
import 'package:ai_chat_bot/domain/repositories/llm/llm_repository.dart';
import 'package:ai_chat_bot/domain/repositories/chat_history/chat_history_repository.dart';
import 'package:ai_chat_bot/domain/repositories/memory/memory_repository.dart';
import 'package:ai_chat_bot/domain/repositories/voice_recording_repository.dart';
import 'package:ai_chat_bot/domain/usecases/generate_text_with_context_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/generate_text_with_memory_context_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/save_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/delete_chat_session_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_memory_items_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/save_memory_item_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/delete_memory_item_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/search_memory_items_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/get_relevant_memory_for_context_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/start_voice_recording_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/stop_voice_recording_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/cancel_voice_recording_usecase.dart';

final GetIt sl = GetIt.instance;

void init() {
  // Local Data Sources
  sl.registerLazySingleton<HiveStorageLocalDataSource>(
    ImplHiveStorageLocalDataSource.new,
  );

  // Remote Data Sources
  sl.registerLazySingleton<GeminiRemoteDataSource>(
    ImplGeminiRemoteDataSource.new,
  );

  // Repositories
  sl.registerLazySingleton<LLMRepository>(
    () => ImplGeminiRepository(sl.get<GeminiRemoteDataSource>()),
  );

  sl.registerLazySingleton<ChatHistoryRepository>(
    () => ImplChatHistoryRepository(sl.get()),
  );

  sl.registerLazySingleton<MemoryRepository>(
    () => ImplMemoryRepository(sl.get()),
  );

  sl.registerLazySingleton<VoiceRecordingRepository>(
    VoiceRecordingRepositoryImpl.new,
  );

  // Use cases
  sl.registerLazySingleton<GenerateTextWithContextUseCase>(
    () => GenerateTextWithContextUseCase(sl.get()),
  );

  sl.registerLazySingleton<GetRelevantMemoryForContextUseCase>(
    () => GetRelevantMemoryForContextUseCase(sl.get()),
  );

  sl.registerLazySingleton<GenerateTextWithMemoryContextUseCase>(
    () => GenerateTextWithMemoryContextUseCase(sl.get(), sl.get()),
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

  sl.registerLazySingleton<GetMemoryItemsUseCase>(
    () => GetMemoryItemsUseCase(sl.get()),
  );

  sl.registerLazySingleton<SaveMemoryItemUseCase>(
    () => SaveMemoryItemUseCase(sl.get()),
  );

  sl.registerLazySingleton<DeleteMemoryItemUseCase>(
    () => DeleteMemoryItemUseCase(sl.get()),
  );

  sl.registerLazySingleton<SearchMemoryItemsUseCase>(
    () => SearchMemoryItemsUseCase(sl.get()),
  );

  // Voice Recording Use Cases
  sl.registerLazySingleton<StartVoiceRecordingUseCase>(
    () => StartVoiceRecordingUseCase(sl.get()),
  );

  sl.registerLazySingleton<StopVoiceRecordingUseCase>(
    () => StopVoiceRecordingUseCase(sl.get()),
  );

  sl.registerLazySingleton<CancelVoiceRecordingUseCase>(
    () => CancelVoiceRecordingUseCase(sl.get()),
  );

  // BLoCs
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      sl.get<GenerateTextWithMemoryContextUseCase>(),
      sl.get(),
      sl.get(),
    ),
  );

  sl.registerFactory<HistoryBloc>(
    () => HistoryBloc(sl.get(), sl.get(), sl.get()),
  );

  sl.registerFactory<HomeBloc>(() => HomeBloc(sl.get(), sl.get()));

  sl.registerFactory<MemoryBloc>(
    () => MemoryBloc(sl.get(), sl.get(), sl.get(), sl.get(), sl.get()),
  );

  sl.registerFactory<VoiceRecordingBloc>(
    () => VoiceRecordingBloc(sl.get(), sl.get(), sl.get()),
  );
}
