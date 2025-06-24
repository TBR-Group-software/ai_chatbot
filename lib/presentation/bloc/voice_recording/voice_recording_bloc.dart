import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/domain/entities/voice_recording_entity.dart';
import 'package:ai_chat_bot/domain/usecases/start_voice_recording_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/stop_voice_recording_usecase.dart';
import 'package:ai_chat_bot/domain/usecases/cancel_voice_recording_usecase.dart';

part 'voice_recording_event.dart';
part 'voice_recording_state.dart';

/// A BLoC that manages voice recording operations and state.
///
/// This BLoC handles the complete voice recording lifecycle including
/// initialization, recording, stopping, and cancellation. It provides
/// real-time updates on recording status, sound levels, and recognized text.
///
/// The BLoC automatically handles microphone permissions, speech recognition
/// initialization, and stream management. It integrates with the domain layer
/// through use cases for clean architecture compliance.
///
/// Key features:
/// * Real-time voice recording with live text recognition
/// * Automatic permission handling and initialization
/// * Sound level monitoring and visual feedback
/// * Robust error handling and recovery
/// * Clean state management with immutable states
/// * Callback support for completion and cancellation
///
/// Example usage:
/// ```dart
/// // In your widget
/// BlocBuilder<VoiceRecordingBloc, VoiceRecordingState>(
///   builder: (context, state) {
///     if (state.isRecording) {
///       return RecordingIndicator(
///         soundLevel: state.soundLevel,
///         recognizedText: state.recognizedText,
///       );
///     }
///     return RecordButton(
///       onPressed: () => context.read<VoiceRecordingBloc>()
///         .add(StartVoiceRecordingEvent()),
///     );
///   },
/// )
///
/// // Starting recording
/// context.read<VoiceRecordingBloc>().add(StartVoiceRecordingEvent());
///
/// // Stopping with callback
/// context.read<VoiceRecordingBloc>().add(
///   StopVoiceRecordingEvent(
///     onComplete: (text) => _handleRecognizedText(text),
///   ),
/// );
/// ```
class VoiceRecordingBloc extends Bloc<VoiceRecordingEvent, VoiceRecordingState> {

  /// Creates a new [VoiceRecordingBloc] instance.
  ///
  /// All use case parameters are required for proper functionality:
  /// * [_startVoiceRecordingUseCase] handles recording initialization and streaming
  /// * [_stopVoiceRecordingUseCase] manages recording termination and final text retrieval
  /// * [_cancelVoiceRecordingUseCase] handles recording cancellation without saving text
  ///
  /// The BLoC starts in an initial state with no active recording.
  VoiceRecordingBloc(
    this._startVoiceRecordingUseCase,
    this._stopVoiceRecordingUseCase,
    this._cancelVoiceRecordingUseCase,
  ) : super(VoiceRecordingState.initial()) {
    on<StartVoiceRecordingEvent>(_onStartRecording);
    on<StopVoiceRecordingEvent>(_onStopRecording);
    on<CancelVoiceRecordingEvent>(_onCancelRecording);
    on<_VoiceRecordingUpdateEvent>(_onRecordingUpdate);
  }
  final StartVoiceRecordingUseCase _startVoiceRecordingUseCase;
  final StopVoiceRecordingUseCase _stopVoiceRecordingUseCase;
  final CancelVoiceRecordingUseCase _cancelVoiceRecordingUseCase;

  StreamSubscription<VoiceRecordingEntity>? _recordingSubscription;

  @override
  Future<void> close() {
    _recordingSubscription?.cancel();
    return super.close();
  }

  /// Handles the start voice recording event.
  ///
  /// Initiates voice recording with automatic permission checking and
  /// microphone initialization. Sets up a stream subscription to receive
  /// real-time recording updates including sound levels and recognized text.
  ///
  /// The method performs these operations:
  /// 1. Validates current state (prevents duplicate recordings)
  /// 2. Sets initialization state for UI feedback
  /// 3. Cancels any existing recording subscription
  /// 4. Starts recording stream and sets up event handlers
  /// 5. Handles errors gracefully with user-friendly messages
  ///
  /// [event] The start recording event (no additional parameters)
  /// [emit] The state emitter for updating the UI
  ///
  /// Throws no exceptions directly, but may emit error states if:
  /// * Microphone permissions are denied
  /// * Speech recognition is unavailable
  /// * Device microphone is not accessible
  Future<void> _onStartRecording(
    StartVoiceRecordingEvent event,
    Emitter<VoiceRecordingState> emit,
  ) async {
    try {
      // Don't start if already recording
      if (state.isRecording || state.isInitializing) {
        return;
      }

      emit(state.copyWith(isInitializing: true));

      // Cancel any existing subscription
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;

      // Start recording and listen to updates
      _recordingSubscription = _startVoiceRecordingUseCase().listen(
        (recordingEntity) {
          if (!isClosed) {
            add(_VoiceRecordingUpdateEvent(recordingEntity));
          }
        },
        onError: (Object error) {
          if (!isClosed) {
            add(_VoiceRecordingUpdateEvent(
              VoiceRecordingEntity.error(error.toString()),
            ),);
          }
        },
        onDone: () {
          // Handle stream completion if needed
        },
      );
    } catch (error) {
      emit(state.copyWith(
        isInitializing: false,
        isRecording: false,
        error: 'Failed to start recording: $error',
      ),);
    }
  }

  /// Handles the stop voice recording event.
  ///
  /// Terminates the active recording session and retrieves the final
  /// recognized text. The method ensures proper cleanup of resources
  /// and provides the recognized text through an optional callback.
  ///
  /// The stopping process includes:
  /// 1. State validation to prevent duplicate stop requests
  /// 2. Setting stopping state for UI feedback
  /// 3. Calling the stop use case to finalize recording
  /// 4. Cleaning up stream subscriptions
  /// 5. Emitting completed state with final text
  /// 6. Executing the completion callback if provided
  ///
  /// [event] The stop recording event, may contain an optional completion callback
  /// [emit] The state emitter for updating the UI
  ///
  /// The [event.onComplete] callback receives the final recognized text
  /// and is called after the state has been updated to completed.
  Future<void> _onStopRecording(
    StopVoiceRecordingEvent event,
    Emitter<VoiceRecordingState> emit,
  ) async {
    try {
      // Don't stop if already stopping
      if (state.isStopping) {
        return;
      }

      // Allow stopping even if isRecording is false (to handle edge cases)
      emit(state.copyWith(isStopping: true));

      // Stop recording and get final text
      final finalText = await _stopVoiceRecordingUseCase();

      // Cancel subscription
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;

      // Emit final state with recognized text
      if (!isClosed) {
        emit(VoiceRecordingState.completed(finalText));
        
        // Call the callback with the final text
        event.onComplete?.call(finalText);
      }
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          isStopping: false,
          error: 'Failed to stop recording: $error',
        ),);
      }
    }
  }

  /// Handles the cancel voice recording event.
  ///
  /// Immediately terminates the recording session without saving any
  /// recognized text. This is used when the user wants to discard
  /// the current recording attempt.
  ///
  /// The cancellation process:
  /// 1. Validates current state to prevent duplicate cancellations
  /// 2. Sets cancelling state for UI feedback
  /// 3. Calls the cancel use case to terminate recording
  /// 4. Cleans up all resources and subscriptions
  /// 5. Resets to initial state
  /// 6. Executes the cancellation callback if provided
  ///
  /// [event] The cancel recording event, may contain an optional cancellation callback
  /// [emit] The state emitter for updating the UI
  ///
  /// The [event.onCancel] callback is executed after the state has been
  /// reset to initial, allowing the UI to respond to the cancellation.
  Future<void> _onCancelRecording(
    CancelVoiceRecordingEvent event,
    Emitter<VoiceRecordingState> emit,
  ) async {
    try {
      // Don't cancel if already cancelling
      if (state.isCancelling) {
        return;
      }

      emit(state.copyWith(isCancelling: true));

      // Cancel recording
      await _cancelVoiceRecordingUseCase();

      // Cancel subscription
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;

      // Reset to initial state
      if (!isClosed) {
        emit(VoiceRecordingState.initial());
        
        // Call the callback
        event.onCancel?.call();
      }
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          isCancelling: false,
          error: 'Failed to cancel recording: $error',
        ),);
      }
    }
  }

  /// Handles real-time voice recording updates from the stream.
  ///
  /// Processes updates from the recording stream and updates the state
  /// with current recording information including sound levels, recognized
  /// text, and recording duration. This method ensures the UI stays
  /// synchronized with the recording progress.
  ///
  /// The method handles both successful updates and error conditions:
  /// * For successful updates: extracts recording data and updates state
  /// * For errors: resets recording flags and displays error message
  /// * Ignores updates if the BLoC has been closed
  ///
  /// [event] Internal event containing the recording entity with current data
  /// [emit] The state emitter for updating the UI
  ///
  /// This is an internal method triggered automatically by the recording
  /// stream and should not be called directly from external code.
  void _onRecordingUpdate(
    _VoiceRecordingUpdateEvent event,
    Emitter<VoiceRecordingState> emit,
  ) {
    // Don't process updates if BLoC is closed
    if (isClosed) {
      return;
    }
    
    final recordingEntity = event.recordingEntity;

    if (recordingEntity.hasError) {
      emit(state.copyWith(
        isInitializing: false,
        isRecording: false,
        isStopping: false,
        isCancelling: false,
        error: recordingEntity.errorMessage,
      ),);
      return;
    }

    emit(state.copyWith(
      isInitializing: false,
      isRecording: recordingEntity.isRecording,
      isListening: recordingEntity.isListening,
      soundLevel: recordingEntity.soundLevel,
      recognizedText: recordingEntity.recognizedText,
      recordingDuration: recordingEntity.recordingDuration,
    ),);
  }
}

/// Internal event for voice recording updates.
///
/// This private event is used internally by the BLoC to handle
/// real-time updates from the recording stream. It should not
/// be used directly by external code.
///
/// [recordingEntity] The current recording data from the stream
class _VoiceRecordingUpdateEvent extends VoiceRecordingEvent {

  const _VoiceRecordingUpdateEvent(this.recordingEntity);
  final VoiceRecordingEntity recordingEntity;
} 
