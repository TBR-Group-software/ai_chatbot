part of 'voice_recording_bloc.dart';

/// State class representing the current status of voice recording operations.
///
/// This immutable state class contains all the information needed to
/// render the voice recording UI and track recording progress. It provides
/// comprehensive state management for the entire recording lifecycle.
///
/// The state includes real-time data such as sound levels, recognized text,
/// and recording duration, as well as operational flags for different
/// recording phases and error handling.
///
/// Key state properties:
/// * Recording status flags for different operational phases
/// * Real-time audio data (sound level, duration)
/// * Live text recognition results
/// * Error information for user feedback
/// * Completion status for UI transitions
///
/// Example usage in widgets:
/// ```dart
/// BlocBuilder<VoiceRecordingBloc, VoiceRecordingState>(
///   builder: (context, state) {
///     // Show different UI based on state
///     if (state.isInitializing) {
///       return const CircularProgressIndicator();
///     }
///
///     if (state.isRecording) {
///       return Column(
///         children: [
///           SoundLevelIndicator(level: state.soundLevel),
///           Text('Recording: ${state.recordingDuration}'),
///           Text('Recognized: ${state.recognizedText}'),
///           if (state.isListening) const Icon(Icons.mic),
///         ],
///       );
///     }
///
///     if (state.error != null) {
///       return ErrorWidget(message: state.error!);
///     }
///
///     return RecordButton(
///       onPressed: () => context.read<VoiceRecordingBloc>()
///         .add(StartVoiceRecordingEvent()),
///     );
///   },
/// )
/// ```
class VoiceRecordingState {
  /// Creates a new voice recording state.
  ///
  /// All parameters are required to ensure complete state representation.
  /// Use the factory constructors [initial] and [completed] for common
  /// state configurations, or [copyWith] for incremental updates.
  ///
  /// Parameters:
  /// * [isInitializing] - Whether the system is currently initializing
  /// * [isRecording] - Whether recording is currently active
  /// * [isListening] - Whether speech recognition is actively listening
  /// * [isStopping] - Whether stop operation is in progress
  /// * [isCancelling] - Whether cancellation is in progress
  /// * [soundLevel] - Current audio input level (0.0 to 1.0)
  /// * [recognizedText] - Current recognized text from speech-to-text
  /// * [recordingDuration] - Duration of current recording session
  /// * [error] - Optional error message for user feedback
  /// * [isCompleted] - Whether recording has been completed successfully
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

  /// Creates the initial voice recording state.
  factory VoiceRecordingState.initial() {
    return const VoiceRecordingState(
      isInitializing: false,
      isRecording: false,
      isListening: false,
      isStopping: false,
      isCancelling: false,
      soundLevel: 0,
      recognizedText: '',
      recordingDuration: Duration.zero,
      isCompleted: false,
    );
  }

  /// Creates a completed recording state with final text.
  factory VoiceRecordingState.completed(String finalText) {
    return VoiceRecordingState(
      isInitializing: false,
      isRecording: false,
      isListening: false,
      isStopping: false,
      isCancelling: false,
      soundLevel: 0,
      recognizedText: finalText,
      recordingDuration: Duration.zero,
      isCompleted: true,
    );
  }

  /// Whether the recording system is currently initializing.
  ///
  /// This flag is true during the initial setup phase when the BLoC
  /// is requesting permissions, initializing speech recognition, and
  /// setting up audio streams. The UI should show loading indicators
  /// during this phase.
  final bool isInitializing;

  /// Whether voice recording is currently active.
  ///
  /// When true, the microphone is capturing audio and speech recognition
  /// is processing the input. This is the main recording state that
  /// triggers recording UI elements like sound visualizers and stop buttons.
  final bool isRecording;

  /// Whether the speech recognition engine is actively listening.
  ///
  /// This flag indicates if the speech recognition service is currently
  /// processing audio input. It may differ from [isRecording] in cases
  /// where recording is active but speech recognition is temporarily paused.
  final bool isListening;

  /// Whether the recording is in the process of stopping.
  ///
  /// This flag is true when the stop operation has been initiated but
  /// not yet completed. The UI should disable stop buttons and show
  /// processing indicators during this phase.
  final bool isStopping;

  /// Whether the recording is in the process of being canceled.
  ///
  /// This flag is true when cancellation has been requested but the
  /// cleanup process is not yet complete. The UI should show appropriate
  /// feedback during cancellation.
  final bool isCancelling;

  /// Current microphone sound level from 0.0 to 1.0.
  ///
  /// This value represents the current audio input level and can be used
  /// for visual feedback such as sound level meters or pulsing animations.
  /// A value of 0.0 indicates silence, while 1.0 represents maximum volume.
  ///
  /// Updated in real-time during recording for smooth visual feedback.
  final double soundLevel;

  /// Currently recognized text from speech-to-text processing.
  ///
  /// This string contains the live transcription of the user's speech.
  /// It updates in real-time as the speech recognition engine processes
  /// audio input, allowing for live preview of the transcription.
  ///
  /// The text may change during recording as the recognition engine
  /// refines its interpretation of the audio.
  final String recognizedText;

  /// Duration of the current recording session.
  ///
  /// This duration starts from zero when recording begins and updates
  /// continuously during the recording session. It can be used to
  /// display recording timers or enforce maximum recording limits.
  ///
  /// Resets to [Duration.zero] when recording stops or is canceled.
  final Duration recordingDuration;

  /// Error message if any operation failed.
  ///
  /// When not null, this string contains a user-friendly error message
  /// that should be displayed to inform the user of any issues with
  /// the recording process, such as permission denied or device unavailable.
  ///
  /// The error is cleared when starting a new recording operation.
  final String? error;

  /// Whether the recording has been completed successfully.
  ///
  /// This flag is true when a recording session has been completed
  /// and final text has been captured. It's used to trigger UI
  /// transitions and handle the completed recording result.
  final bool isCompleted;

  /// Creates a copy of this state with modified properties.
  /// Returns a new [VoiceRecordingState] with specified properties updated
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

  /// Checks if any recording operation is currently in progress.
  bool get isProcessing => isInitializing || isStopping || isCancelling;
}
