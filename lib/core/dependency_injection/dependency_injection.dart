import 'package:ai_chat_bot/domain/repositories/impl_llm_repository.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ai_chat_bot/data/services/gemini_service.dart';
import 'package:ai_chat_bot/domain/repositories/llm_repository.dart';
import 'package:ai_chat_bot/domain/usecases/generate_text_usecase.dart';

final GetIt sl = GetIt.instance;

void init() {
  // Services
  sl.registerLazySingleton<GeminiService>(
    () => GeminiService(),
  );

  //Repositories
  sl.registerLazySingleton<LLMRepository>(
    () => ImplLLMRepository(sl.get()),
  );

  // Use cases
  sl.registerLazySingleton<GenerateTextUseCase>(
    () => GenerateTextUseCase(sl.get()),
  );

  // Blocs
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(sl.get()),
  );
}
