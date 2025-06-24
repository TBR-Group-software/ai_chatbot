import 'package:ai_chat_bot/domain/entities/voice_recording_entity.dart';

/// Repository interface for voice recording operations
abstract class VoiceRecordingRepository {
  /// Initialize the speech recognition service
  /// Returns true if initialization was successful
  Future<bool> initialize();

  /// Start voice recording and speech recognition
  /// 
  /// Returns a stream of [VoiceRecordingEntity] updates
  Stream<VoiceRecordingEntity> startRecording();

  /// Stop voice recording and speech recognition
  /// 
  /// Returns the final recognized text
  Future<String> stopRecording();

  /// Cancel voice recording without returning text
  Future<void> cancelRecording();

  /// Check if the device supports speech recognition
  Future<bool> isAvailable();

  /// Request microphone permissions
  Future<bool> requestPermissions();

  /// Check if microphone permissions are granted
  Future<bool> hasPermissions();

  /// Get the list of available locales for speech recognition
  Future<List<String>> getAvailableLanguages();

  /// Dispose of resources
  Future<void> dispose();
} 
