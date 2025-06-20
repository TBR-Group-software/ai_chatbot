import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/voice_recording/voice_recording_bloc.dart';
import 'wave_visualization.dart';

/// Central controls widget containing waveform and timer
class VoiceRecordingControls extends StatelessWidget {
  final VoiceRecordingState state;
  final AnimationController waveController;
  final ThemeData theme;
  final CustomColors customColors;

  const VoiceRecordingControls({
    super.key,
    required this.state,
    required this.waveController,
    required this.theme,
    required this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 48,
            child: WaveVisualization(
              state: state,
              waveController: waveController,
              theme: theme,
              customColors: customColors,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(state.recordingDuration),
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
} 