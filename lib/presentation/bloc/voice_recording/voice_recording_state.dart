part of 'voice_recording_bloc.dart';

/// State class for voice recording BLoC
class VoiceRecordingState {
  final bool isInitializing;
  final bool isRecording;
  final bool isListening;
  final bool isStopping;
  final bool isCancelling;
  final double soundLevel;
  final String recognizedText;
  final Duration recordingDuration;
  final String? error;
  final bool isCompleted;

  const VoiceRecordingState({
    required this.isInitializing,
    required this.isRecording,
    required this.isListening,
    required this.isStopping,
    required this.isCancelling,
    required this.soundLevel,
    required this.recognizedText,
    required this.recordingDuration,
    this.error,
    required this.isCompleted,
  });

  /// Factory constructor for initial state
  factory VoiceRecordingState.initial() {
    return const VoiceRecordingState(
      isInitializing: false,
      isRecording: false,
      isListening: false,
      isStopping: false,
      isCancelling: false,
      soundLevel: 0.0,
      recognizedText: '',
      recordingDuration: Duration.zero,
      error: null,
      isCompleted: false,
    );
  }

  /// Factory constructor for completed state
  factory VoiceRecordingState.completed(String finalText) {
    return VoiceRecordingState(
      isInitializing: false,
      isRecording: false,
      isListening: false,
      isStopping: false,
      isCancelling: false,
      soundLevel: 0.0,
      recognizedText: finalText,
      recordingDuration: Duration.zero,
      error: null,
      isCompleted: true,
    );
  }

  /// Copy with method for immutable updates
  VoiceRecordingState copyWith({
    bool? isInitializing,
    bool? isRecording,
    bool? isListening,
    bool? isStopping,
    bool? isCancelling,
    double? soundLevel,
    String? recognizedText,
    Duration? recordingDuration,
    String? error,
    bool? isCompleted,
  }) {
    return VoiceRecordingState(
      isInitializing: isInitializing ?? this.isInitializing,
      isRecording: isRecording ?? this.isRecording,
      isListening: isListening ?? this.isListening,
      isStopping: isStopping ?? this.isStopping,
      isCancelling: isCancelling ?? this.isCancelling,
      soundLevel: soundLevel ?? this.soundLevel,
      recognizedText: recognizedText ?? this.recognizedText,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      error: error ?? this.error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Check if any operation is in progress
  bool get isProcessing => isInitializing || isStopping || isCancelling;
}
