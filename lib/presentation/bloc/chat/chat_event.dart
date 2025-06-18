part of 'chat_bloc.dart';

abstract class ChatEvent {}

class GenerateTextEvent extends ChatEvent {
  final String prompt;
  final bool isRetry;
  GenerateTextEvent(this.prompt, {this.isRetry = false});
}

class SendMessageEvent extends ChatEvent {
  final String messageText;
  SendMessageEvent(this.messageText);
}

class EditAndResendMessageEvent extends ChatEvent {
  final String messageId;
  final String newMessageText;
  EditAndResendMessageEvent(this.messageId, this.newMessageText);
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

class RetryLastRequestEvent extends ChatEvent {
  RetryLastRequestEvent();
}