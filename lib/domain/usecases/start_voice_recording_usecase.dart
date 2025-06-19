import '../entities/voice_recording_entity.dart';
import '../repositories/voice_recording_repository.dart';

/// Use case for starting voice recording
/// 
/// Handles permission checking, initialization, and starting the recording stream
class StartVoiceRecordingUseCase {
  final VoiceRecordingRepository _repository;

  const StartVoiceRecordingUseCase(this._repository);

  /// Execute the use case to start voice recording
  /// Returns a stream of VoiceRecordingEntity updates
  Stream<VoiceRecordingEntity> call() {
    // Repository now handles all initialization and permission checks internally
    return _repository.startRecording();
  }
} 