/// Voice recording entity representing the current state of voice recording
class VoiceRecordingEntity {

  const VoiceRecordingEntity({
    required this.isRecording,
    required this.isListening,
    required this.soundLevel,
    required this.recognizedText,
    required this.hasError,
    this.errorMessage,
    required this.recordingDuration,
  });

  /// Factory constructor for initial state
  factory VoiceRecordingEntity.initial() {
    return const VoiceRecordingEntity(
      isRecording: false,
      isListening: false,
      soundLevel: 0,
      recognizedText: '',
      hasError: false,
      recordingDuration: Duration.zero,
    );
  }

  /// Factory constructor for recording state
  factory VoiceRecordingEntity.recording({
    required bool isListening,
    required double soundLevel,
    required String recognizedText,
    required Duration recordingDuration,
  }) {
    return VoiceRecordingEntity(
      isRecording: true,
      isListening: isListening,
      soundLevel: soundLevel,
      recognizedText: recognizedText,
      hasError: false,
      recordingDuration: recordingDuration,
    );
  }

  /// Factory constructor for error state
  factory VoiceRecordingEntity.error(String errorMessage) {
    return VoiceRecordingEntity(
      isRecording: false,
      isListening: false,
      soundLevel: 0,
      recognizedText: '',
      hasError: true,
      errorMessage: errorMessage,
      recordingDuration: Duration.zero,
    );
  }
  final bool isRecording;
  final bool isListening;
  final double soundLevel;
  final String recognizedText;
  final bool hasError;
  final String? errorMessage;
  final Duration recordingDuration;

  /// Copy with method for immutable updates
  VoiceRecordingEntity copyWith({
    bool? isRecording,
    bool? isListening,
    double? soundLevel,
    String? recognizedText,
    bool? hasError,
    String? errorMessage,
    Duration? recordingDuration,
  }) {
    return VoiceRecordingEntity(
      isRecording: isRecording ?? this.isRecording,
      isListening: isListening ?? this.isListening,
      soundLevel: soundLevel ?? this.soundLevel,
      recognizedText: recognizedText ?? this.recognizedText,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      recordingDuration: recordingDuration ?? this.recordingDuration,
    );
  }
}
