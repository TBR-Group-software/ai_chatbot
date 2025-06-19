import '../repositories/voice_recording_repository.dart';

/// Use case for canceling voice recording
/// 
/// Cancels the recording without returning any recognized text
class CancelVoiceRecordingUseCase {
  final VoiceRecordingRepository _repository;

  const CancelVoiceRecordingUseCase(this._repository);

  /// Execute the use case to cancel voice recording
  Future<void> call() async {
    try {
      await _repository.cancelRecording();
    } catch (error) {
      throw Exception('Failed to cancel recording: ${error.toString()}');
    }
  }
} 