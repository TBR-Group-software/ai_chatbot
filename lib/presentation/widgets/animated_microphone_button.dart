import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/voice_recording/voice_recording_bloc.dart';

/// Recording button visual state for switch statements
enum RecordingButtonState {
  processing,
  recording,
  idle,
}

/// Animated microphone button widget that handles the visual representation
/// and animations for voice recording states
class AnimatedMicrophoneButton extends StatelessWidget {
  final VoiceRecordingState state;
  final Animation<double> pulseAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const AnimatedMicrophoneButton({
    super.key,
    required this.state,
    required this.pulseAnimation,
    required this.scaleAnimation,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  RecordingButtonState get _buttonState {
    if (state.isProcessing) return RecordingButtonState.processing;
    if (state.isRecording) return RecordingButtonState.recording;
    return RecordingButtonState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;

    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: AnimatedBuilder(
        animation: Listenable.merge([pulseAnimation, scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getBackgroundColor(theme, customColors),
                boxShadow: _getBoxShadow(customColors),
              ),
              child: Transform.scale(
                scale: state.isRecording ? pulseAnimation.value : 1.0,
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(theme, customColors),
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme, CustomColors customColors) {
    switch (_buttonState) {
      case RecordingButtonState.processing:
        return customColors.onSurfaceDim;
      case RecordingButtonState.recording:
        return theme.colorScheme.error;
      case RecordingButtonState.idle:
        return theme.colorScheme.primary;
    }
  }

  List<BoxShadow> _getBoxShadow(CustomColors customColors) {
    switch (state.isRecording) {
      case true:
        return [
          BoxShadow(
            color: customColors.microphoneShadow,
            blurRadius: 20 * pulseAnimation.value,
            spreadRadius: 5 * pulseAnimation.value,
          ),
        ];
      case false:
        return [
          BoxShadow(
            color: customColors.buttonShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
    }
  }

  IconData _getIcon() {
    switch (_buttonState) {
      case RecordingButtonState.processing:
        return Icons.hourglass_empty;
      case RecordingButtonState.recording:
        return Icons.stop;
      case RecordingButtonState.idle:
        return Icons.mic;
    }
  }

  Color _getIconColor(ThemeData theme, CustomColors customColors) {
    switch (_buttonState) {
      case RecordingButtonState.processing:
        return theme.colorScheme.onSurface;
      case RecordingButtonState.recording:
        return Colors.white;
      case RecordingButtonState.idle:
        return theme.colorScheme.onPrimary;
    }
  }
} 