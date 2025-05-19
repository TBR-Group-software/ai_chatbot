abstract class ChatEvent {}

class GenerateTextEvent extends ChatEvent {
  final String prompt;
  GenerateTextEvent(this.prompt);
}