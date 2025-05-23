import 'package:ai_chat_bot/domain/usecases/generate_text_usecase.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_event.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GenerateTextUseCase _generateTextUseCase;

  ChatBloc(this._generateTextUseCase) : super(ChatState.initial()) {
    on<GenerateTextEvent>((event, emit) async {
      emit(ChatState(isLoading: true));
      try {
        await emit.forEach(
          _generateTextUseCase.call(event.prompt),
          onData:
              (textResponse) => state.copyWith(
                isLoading: false,
                generatedContent: textResponse,
              ),
          onError:
              (error, stackTrace) => state.copyWith(error: error.toString()),
        );
      } catch (error) {
        emit(
          ChatState(
            isLoading: false,
            generatedContent: null,
            error: error.toString(),
          ),
        );
      }
    });
  }
}
