import 'package:flutter/material.dart';
import 'package:ai_chat_bot/presentation/bloc/voice_recording/voice_recording_bloc.dart';

/// Status text widget that displays recording state information
class StatusText extends StatelessWidget {

  const StatusText({
    super.key,
    required this.state,
    required this.theme,
  });
  final VoiceRecordingState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    String statusText;
    if (state.isInitializing) {
      statusText = 'Initializing...';
    } else if (state.isRecording && state.isListening) {
      statusText = 'Recording... (speak freely)';
    } else if (state.isRecording) {
      statusText = 'Recording... (ready for speech)';
    } else if (state.isStopping) {
      statusText = 'Finishing...';
    } else {
      statusText = 'Tap to speak';
    }

    return Text(
      statusText,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
} 
