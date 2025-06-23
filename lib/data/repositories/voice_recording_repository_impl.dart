import 'dart:async';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ai_chat_bot/domain/entities/voice_recording_entity.dart';
import 'package:ai_chat_bot/domain/repositories/voice_recording_repository.dart';

/// Concrete implementation of [VoiceRecordingRepository]
///
/// Uses [speech_to_text](https://pub.dev/packages/speech_to_text) and [permission_handler](https://pub.dev/packages/permission_handler) packages
///
/// [SpeechToText] is used to convert speech to text
///
/// [Permission] is used to request permissions
class VoiceRecordingRepositoryImpl implements VoiceRecordingRepository {
  final SpeechToText _speechToText = SpeechToText();

  StreamController<VoiceRecordingEntity>? _recordingController = StreamController<VoiceRecordingEntity>.broadcast();
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;
  String _currentRecognizedText = '';
  bool _isInitialized = false;
  int _restartAttempts = 0;
  bool _manualControlMode = false; // Flag to disable auto-restarts
  static const int _maxRestartAttempts = 2;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      return _isInitialized = await _speechToText.initialize(onError: _handleError, onStatus: _handleStatusChange);
    } catch (error) {
      return false;
    }
  }

  @override
  Stream<VoiceRecordingEntity> startRecording() async* {
    try {
      // Ensure previous recording is stopped
      await _recordingController?.close();
      _recordingController = StreamController<VoiceRecordingEntity>.broadcast();

      // Reset restart attempts when starting new recording
      _restartAttempts = 0;
      _manualControlMode = true; // Enable manual control mode

      // Check and request permissions first
      final permissionStatus = await Permission.microphone.status;

      if (permissionStatus == PermissionStatus.denied) {
        final requestResult = await Permission.microphone.request();

        if (requestResult != PermissionStatus.granted) {
          if (requestResult == PermissionStatus.permanentlyDenied) {
            yield VoiceRecordingEntity.error(
              'Microphone permission permanently denied. Please enable it in app settings.',
            );
          } else {
            yield VoiceRecordingEntity.error('Microphone permission is required to record voice messages.');
          }
          return;
        }
      } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
        yield VoiceRecordingEntity.error('Microphone permission permanently denied. Please enable it in app settings.');
        return;
      } else if (permissionStatus != PermissionStatus.granted) {
        final requestResult = await Permission.microphone.request();

        if (requestResult != PermissionStatus.granted) {
          yield VoiceRecordingEntity.error('Microphone permission is required to record voice messages.');
          return;
        }
      }

      // Initialize speech recognition if not already done
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          yield VoiceRecordingEntity.error('Failed to initialize speech recognition');
          return;
        }
      }

      // Check if speech recognition is available
      if (!await isAvailable()) {
        yield VoiceRecordingEntity.error('Speech recognition not available on this device');
        return;
      }

      // Start listening
      await _startListening();
      _startRecordingTimer();

      // Yield the stream
      yield* _recordingController!.stream;
    } catch (error) {
      yield VoiceRecordingEntity.error('Failed to start recording: $error');
    }
  }

  @override
  Future<String> stopRecording() async {
    // Add a 1-second delay to capture the last word
    await Future.delayed(const Duration(seconds: 1));

    await _speechToText.stop();
    await _stopRecordingTimer();
    await _recordingController?.close();
    _recordingController = null;
    _manualControlMode = false; // Reset manual control mode

    final finalText = _currentRecognizedText;
    _currentRecognizedText = '';
    return finalText;
  }

  @override
  Future<void> cancelRecording() async {
    await _speechToText.cancel();
    await _stopRecordingTimer();
    await _recordingController?.close();
    _recordingController = null;
    _manualControlMode = false; // Reset manual control mode
    _currentRecognizedText = '';
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // If already initialized, check if speech is available
      if (_isInitialized) {
        return _speechToText.isAvailable;
      }

      // Try to initialize temporarily to check availability
      return await _speechToText.initialize(
        onError: (error) {}, // Temporary error handler for availability check
        onStatus: (status) {}, // Temporary status handler for availability check
      );
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      // First check current status
      final currentStatus = await Permission.microphone.status;

      // If already granted, return true
      if (currentStatus == PermissionStatus.granted) {
        return true;
      }

      // If permanently denied, we can't request again
      if (currentStatus == PermissionStatus.permanentlyDenied) {
        return false;
      }

      // Request permission
      final status = await Permission.microphone.request();

      // Check if granted
      final isGranted = status == PermissionStatus.granted;

      return isGranted;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }

    final locales = await _speechToText.locales();
    return locales.map((locale) => locale.localeId).toList();
  }

  @override
  Future<void> dispose() async {
    await cancelRecording();
    await _recordingController?.close();
    _recordingController = null;
  }

  /// Start listening for speech input
  Future<void> _startListening() async {
    try {
      _recordingStartTime = DateTime.now();
      _currentRecognizedText = '';

      await _speechToText.listen(
        onResult: _handleSpeechResult,
        listenFor: const Duration(minutes: 10), // Extended maximum recording duration
        pauseFor: const Duration(minutes: 5), // Very long pause before auto-stopping
        onSoundLevelChange: _handleSoundLevelChange,
        listenOptions: SpeechListenOptions(listenMode: ListenMode.dictation),
      );
    } catch (error) {
      _handleError(SpeechRecognitionError(error.toString(), true));
    }
  }

  /// Start the recording timer to track duration and emit updates
  void _startRecordingTimer() {
    try {
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        try {
          if (_recordingController?.isClosed ?? true) {
            timer.cancel();
            return;
          }

          final duration =
              _recordingStartTime != null ? DateTime.now().difference(_recordingStartTime!) : Duration.zero;

          // Get current sound level from speech recognition with null safety
          var currentSoundLevel = 0.0;
          try {
            currentSoundLevel = _speechToText.isListening ? (_speechToText.lastSoundLevel) : 0.0;
          } catch (e) {
            // If getting sound level fails, use 0.0
            currentSoundLevel = 0.0;
          }

          final entity = VoiceRecordingEntity.recording(
            isListening: _speechToText.isListening,
            soundLevel: currentSoundLevel,
            recognizedText: _currentRecognizedText,
            recordingDuration: duration,
          );

          _recordingController?.add(entity);
        } catch (error) {
          timer.cancel();
        }
      });
    } catch (error) {
      _handleError(SpeechRecognitionError(error.toString(), true));
    }
  }

  /// Stop the recording timer
  Future<void> _stopRecordingTimer() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingStartTime = null;
  }

  /// Handle speech recognition results
  void _handleSpeechResult(SpeechRecognitionResult result) {
    try {
      _currentRecognizedText = result.recognizedWords as String? ?? '';

      if (_recordingController?.isClosed ?? true) {
        return;
      }

      final duration = _recordingStartTime != null ? DateTime.now().difference(_recordingStartTime!) : Duration.zero;

      // Get sound level safely
      var soundLevel = 0.0;
      try {
        soundLevel = _speechToText.lastSoundLevel;
      } catch (e) {
        soundLevel = 0.0;
      }

      final entity = VoiceRecordingEntity.recording(
        isListening: _speechToText.isListening,
        soundLevel: soundLevel,
        recognizedText: _currentRecognizedText,
        recordingDuration: duration,
      );

      _recordingController?.add(entity);
    } catch (error) {
      _handleError(SpeechRecognitionError(error.toString(), true));
    }
  }

  /// Handle sound level changes for waveform visualization
  void _handleSoundLevelChange(double level) {
    try {
      if (_recordingController?.isClosed ?? true) {
        return;
      }

      final duration = _recordingStartTime != null ? DateTime.now().difference(_recordingStartTime!) : Duration.zero;

      final entity = VoiceRecordingEntity.recording(
        isListening: _speechToText.isListening,
        soundLevel: level,
        recognizedText: _currentRecognizedText,
        recordingDuration: duration,
      );

      _recordingController?.add(entity);
    } catch (error) {
      // Don't call _handleError here to avoid infinite loops
    }
  }

  /// Handle speech recognition status changes
  void _handleStatusChange(String status) {
    // If speech recognition stops unexpectedly during recording, restart it (with limits)
    if (status == 'done' && _recordingController?.isClosed == false && !_manualControlMode) {
      if (_restartAttempts < _maxRestartAttempts) {
        _restartAttempts++;

        // Wait a brief moment then restart listening
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (_recordingController?.isClosed == false) {
            try {
              await _startListening();
            } catch (error) {
              _handleError(SpeechRecognitionError(error.toString(), true));
            }
          }
        });
      }
    } else if (_manualControlMode && status == 'done') {
      // Don't emit error, just let it stay in current state
    }
  }

  /// Handle speech recognition errors
  void _handleError(SpeechRecognitionError error) {
    try {
      var errorMessage = 'Unknown error occurred';
      var shouldShowToUser = true;

      // Handle different types of errors
      try {
        // Try to access errorMsg property safely
        final rawError = error.errorMsg;

        // Don't show user errors during automatic restart attempts
        if (rawError == 'error_no_match' && _restartAttempts < _maxRestartAttempts) {
          shouldShowToUser = false;
          return;
        }

        // Convert technical errors to user-friendly messages
        switch (rawError) {
          case 'error_no_match':
            errorMessage = 'No speech detected. Please try speaking again.';
          case 'error_speech_timeout':
            errorMessage = 'Speech timeout. Please try again.';
          case 'error_audio':
            errorMessage = 'Audio error. Please check your microphone.';
          case 'error_network':
            errorMessage = 'Network error. Please check your connection.';
          case 'error_network_timeout':
            errorMessage = 'Network timeout. Please try again.';
          case 'error_client':
            errorMessage = 'Recognition error. Please try again.';
          case 'error_server':
            errorMessage = 'Server error. Please try again later.';
          case 'error_insufficient_permissions':
            errorMessage = 'Microphone permission required.';
          default:
            errorMessage = 'Speech recognition failed. Please try again.';
        }
      } catch (e) {
        // If accessing errorMsg fails, just use toString
        errorMessage = 'Speech recognition failed. Please try again.';
      }

      if (shouldShowToUser) {
        final entity = VoiceRecordingEntity.error(errorMessage);
        _recordingController?.add(entity);
      }
    } catch (e) {
      // Last resort - try to emit a generic error
      try {
        if (!(_recordingController?.isClosed ?? true)) {
          _recordingController?.add(VoiceRecordingEntity.error('An unexpected error occurred'));
        }
      } catch (finalError) {
        // Final error handler failed: $finalError
      }
    }
  }
}
