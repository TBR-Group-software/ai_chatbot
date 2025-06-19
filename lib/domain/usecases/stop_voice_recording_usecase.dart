import '../repositories/voice_recording_repository.dart';

/// Use case for stopping voice recording
/// 
/// Returns the final recognized text from the recording session
class StopVoiceRecordingUseCase {
  final VoiceRecordingRepository _repository;

  const StopVoiceRecordingUseCase(this._repository);

  /// Execute the use case to stop voice recording
  /// 
  /// Returns the final recognized text
  Future<String> call() async {
    try {
      return await _repository.stopRecording();
    } catch (error) {
      throw Exception('Failed to stop recording: ${error.toString()}');
    }
  }
} 