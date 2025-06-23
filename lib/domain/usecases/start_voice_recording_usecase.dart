import 'package:ai_chat_bot/domain/entities/voice_recording_entity.dart';
import 'package:ai_chat_bot/domain/repositories/voice_recording_repository.dart';

/// Use case for starting voice recording
///
/// Initiates a new voice recording session with automatic permission handling
/// and microphone initialization. Returns a stream of recording updates
///
/// Handles:
/// - Permission checking and requesting
/// - Microphone initialization
/// - Real-time recording status updates
/// - Error handling and recovery
///
/// Uses [VoiceRecordingRepository] for recording operations
class StartVoiceRecordingUseCase {

  /// Constructor for start voice recording use case
  ///
  /// [_repository] The voice recording repository for recording operations
  const StartVoiceRecordingUseCase(this._repository);
  final VoiceRecordingRepository _repository;

  /// Execute the use case to start voice recording
  ///
  /// Initiates recording with automatic permission checks and initialization
  /// Returns a stream of [VoiceRecordingEntity] updates containing:
  /// - Recording status and progress
  /// - Real-time recognized text
  /// - Sound level indicators
  /// - Error states if any issues occur
  Stream<VoiceRecordingEntity> call() {
    // Repository now handles all initialization and permission checks internally
    return _repository.startRecording();
  }
} 
