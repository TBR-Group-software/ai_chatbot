part of 'chat_bloc.dart';

abstract class ChatEvent {}

class GenerateTextEvent extends ChatEvent {
  final String prompt;
  GenerateTextEvent(this.prompt);
}

class SendMessageEvent extends ChatEvent {
  final String messageText;
  SendMessageEvent(this.messageText);
}

class LoadChatSessionEvent extends ChatEvent {
  final String sessionId;
  LoadChatSessionEvent(this.sessionId);
}

class SaveChatSessionEvent extends ChatEvent {
  SaveChatSessionEvent();
}

class CreateNewSessionEvent extends ChatEvent {
  CreateNewSessionEvent();
}