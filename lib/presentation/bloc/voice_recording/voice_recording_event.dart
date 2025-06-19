part of 'voice_recording_bloc.dart';

/// Base class for all voice recording events
abstract class VoiceRecordingEvent {
  const VoiceRecordingEvent();
}

/// Event to start voice recording
class StartVoiceRecordingEvent extends VoiceRecordingEvent {
  const StartVoiceRecordingEvent();
}

/// Event to stop voice recording
class StopVoiceRecordingEvent extends VoiceRecordingEvent {
  final void Function(String recognizedText)? onComplete;

  const StopVoiceRecordingEvent({this.onComplete});
}

/// Event to cancel voice recording
class CancelVoiceRecordingEvent extends VoiceRecordingEvent {
  final VoidCallback? onCancel;

  const CancelVoiceRecordingEvent({this.onCancel});
} 