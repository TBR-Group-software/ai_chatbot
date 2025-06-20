import 'package:flutter/material.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/presentation/bloc/voice_recording/voice_recording_bloc.dart';

/// Animated microphone icon widget with pulse effect
class MicrophoneIcon extends StatelessWidget {

  const MicrophoneIcon({
    super.key,
    required this.state,
    required this.pulseAnimation,
    required this.theme,
    required this.customColors,
  });
  final VoiceRecordingState state;
  final Animation<double> pulseAnimation;
  final ThemeData theme;
  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: state.isRecording ? pulseAnimation.value : 1.0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state.isRecording
                  ? theme.colorScheme.primary
                  : customColors.onSurfaceDim,
              boxShadow: state.isRecording
                  ? [
                      BoxShadow(
                        color: customColors.microphoneShadow,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              state.isRecording ? Icons.mic : Icons.mic_off,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      },
    );
  }
} 
