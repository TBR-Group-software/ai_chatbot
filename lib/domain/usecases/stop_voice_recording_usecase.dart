import 'package:ai_chat_bot/domain/repositories/voice_recording_repository.dart';

/// Use case for stopping voice recording
///
/// Handles the termination of an active voice recording session
/// and retrieves the final recognized text from the recording
///
/// Uses [VoiceRecordingRepository] for recording operations
class StopVoiceRecordingUseCase {

  /// Constructor for stop voice recording use case
  ///
  /// [_repository] The voice recording repository for recording operations
  const StopVoiceRecordingUseCase(this._repository);
  final VoiceRecordingRepository _repository;

  /// Execute the use case to stop voice recording
  ///
  /// Stops the active recording session and returns the final recognized text
  /// Throws [Exception] if stopping the recording fails
  /// Returns the complete recognized text from the recording session
  Future<String> call() async {
    try {
      return await _repository.stopRecording();
    } catch (error) {
      throw Exception('Failed to stop recording: $error');
    }
  }
} 
