import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/voice_recording_entity.dart';
import '../../../domain/usecases/start_voice_recording_usecase.dart';
import '../../../domain/usecases/stop_voice_recording_usecase.dart';
import '../../../domain/usecases/cancel_voice_recording_usecase.dart';

part 'voice_recording_event.dart';
part 'voice_recording_state.dart';

/// BLoC for managing voice recording
class VoiceRecordingBloc extends Bloc<VoiceRecordingEvent, VoiceRecordingState> {
  final StartVoiceRecordingUseCase _startVoiceRecordingUseCase;
  final StopVoiceRecordingUseCase _stopVoiceRecordingUseCase;
  final CancelVoiceRecordingUseCase _cancelVoiceRecordingUseCase;

  StreamSubscription<VoiceRecordingEntity>? _recordingSubscription;

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

  @override
  Future<void> close() {
    _recordingSubscription?.cancel();
    return super.close();
  }

  /// Handle start voice recording event
  Future<void> _onStartRecording(
    StartVoiceRecordingEvent event,
    Emitter<VoiceRecordingState> emit,
  ) async {
    try {
      // Don't start if already recording
      if (state.isRecording || state.isInitializing) {
        return;
      }

      emit(state.copyWith(isInitializing: true, error: null));

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
        onError: (error) {
          if (!isClosed) {
            add(_VoiceRecordingUpdateEvent(
              VoiceRecordingEntity.error(error.toString()),
            ));
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
        error: 'Failed to start recording: ${error.toString()}',
      ));
    }
  }

  /// Handle stop voice recording event
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
          error: 'Failed to stop recording: ${error.toString()}',
        ));
      }
    }
  }

  /// Handle cancel voice recording event
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
          error: 'Failed to cancel recording: ${error.toString()}',
        ));
      }
    }
  }

  /// Handle voice recording updates from the stream
  void _onRecordingUpdate(
    _VoiceRecordingUpdateEvent event,
    Emitter<VoiceRecordingState> emit,
  ) {
    // Don't process updates if BLoC is closed
    if (isClosed) return;
    
    final recordingEntity = event.recordingEntity;

    if (recordingEntity.hasError) {
      emit(state.copyWith(
        isInitializing: false,
        isRecording: false,
        isStopping: false,
        isCancelling: false,
        error: recordingEntity.errorMessage,
      ));
      return;
    }

    emit(state.copyWith(
      isInitializing: false,
      isRecording: recordingEntity.isRecording,
      isListening: recordingEntity.isListening,
      soundLevel: recordingEntity.soundLevel,
      recognizedText: recordingEntity.recognizedText,
      recordingDuration: recordingEntity.recordingDuration,
      error: null,
    ));
  }
}

/// Internal event for voice recording updates
class _VoiceRecordingUpdateEvent extends VoiceRecordingEvent {
  final VoiceRecordingEntity recordingEntity;

  const _VoiceRecordingUpdateEvent(this.recordingEntity);
} 