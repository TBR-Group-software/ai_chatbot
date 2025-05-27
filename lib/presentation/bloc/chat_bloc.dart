import 'package:ai_chat_bot/domain/usecases/generate_text_usecase.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_event.dart';
import 'package:ai_chat_bot/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GenerateTextUseCase _generateTextUseCase;

  ChatBloc(this._generateTextUseCase) : super(ChatState.initial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<GenerateTextEvent>(_onGenerateText);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (event.messageText.trim().isEmpty) return;

    final userMessage = types.TextMessage(
      author: const types.User(id: 'user'),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.messageText,
    );

    final botMessage = types.TextMessage(
      author: const types.User(id: 'bot'),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      status: types.Status.sending,
    );

    final updatedMessages = [botMessage, userMessage, ...state.messages];
    emit(state.copyWith(
      messages: updatedMessages,
      isLoading: true,
    ));

    // Start text generation
    add(GenerateTextEvent(event.messageText));
  }

  Future<void> _onGenerateText(GenerateTextEvent event, Emitter<ChatState> emit) async {
    try {
      await for (final textResponse in _generateTextUseCase.call(event.prompt)) {
        if (textResponse != null && textResponse.text.isNotEmpty) {
          // Get current bot message text and append new chunk
          final currentMessages = List<types.Message>.from(state.messages);
          if (currentMessages.isNotEmpty) {
            final currentBotMessage = currentMessages[0] as types.TextMessage;
            final updatedText = currentBotMessage.text + textResponse.text;
            
            currentMessages[0] = types.TextMessage(
              author: currentBotMessage.author,
              id: currentBotMessage.id,
              text: updatedText,
              status: textResponse.isComplete
                  ? types.Status.delivered
                  : types.Status.sending,
            );
          }
          
          emit(state.copyWith(
            isLoading: false,
            generatedContent: textResponse,
            messages: currentMessages,
          ));
        }
      }
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        generatedContent: null,
        error: error.toString(),
      ));
    }
  }
}
