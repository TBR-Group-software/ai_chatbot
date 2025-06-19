import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/voice_recording/voice_recording_bloc.dart';
import 'audio_waveform_painter.dart';

/// Widget that displays real-time audio waveform visualization
class WaveVisualization extends StatelessWidget {
  final VoiceRecordingState state;
  final AnimationController waveController;
  final ThemeData theme;
  final CustomColors customColors;

  const WaveVisualization({
    super.key,
    required this.state,
    required this.waveController,
    required this.theme,
    required this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: customColors.iconBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: AnimatedBuilder(
        animation: waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: AudioWaveformPainter(
              soundLevel: state.soundLevel,
              animationValue: waveController.value,
              waveformColor: customColors.waveformColor,
              isListening: state.isListening,
              isRecording: state.isRecording,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
} 