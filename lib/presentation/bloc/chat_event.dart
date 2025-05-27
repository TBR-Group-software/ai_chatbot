abstract class ChatEvent {}

class GenerateTextEvent extends ChatEvent {
  final String prompt;
  GenerateTextEvent(this.prompt);
}

class SendMessageEvent extends ChatEvent {
  final String messageText;
  SendMessageEvent(this.messageText);
}