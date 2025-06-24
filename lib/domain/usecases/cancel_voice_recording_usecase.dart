import 'package:ai_chat_bot/domain/repositories/voice_recording_repository.dart';

/// Use case for canceling voice recording
///
/// Terminates an active voice recording session without saving
/// or returning any recognized text. Used when user wants to discard
/// the current recording attempt
///
/// Uses [VoiceRecordingRepository] for recording operations
class CancelVoiceRecordingUseCase {

  /// Constructor for cancel voice recording use case
  ///
  /// [_repository] The voice recording repository for recording operations
  const CancelVoiceRecordingUseCase(this._repository);
  final VoiceRecordingRepository _repository;

  /// Execute the use case to cancel voice recording
  ///
  /// Immediately stops the recording session and discards all recognized text
  /// Cleans up recording resources without returning any content
  /// Throws [Exception] if canceling the recording fails
  Future<void> call() async {
    try {
      await _repository.cancelRecording();
    } catch (error) {
      throw Exception('Failed to cancel recording: $error');
    }
  }
} 
