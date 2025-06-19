import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/voice_recording/voice_recording_bloc.dart';
import 'animated_microphone_button.dart';

/// Voice recording button widget
/// 
/// [onRecordingComplete] is called when the recording is complete
/// 
/// [onTextRecognized] is called when the text is recognized
class VoiceRecordingButton extends StatefulWidget {
  /// Called when the recording is complete
  final VoidCallback? onRecordingComplete;
  
  /// Called when the text is recognized
  final void Function(String text)? onTextRecognized;

  const VoiceRecordingButton({
    super.key,
    this.onRecordingComplete,
    this.onTextRecognized,
  });

  @override
  State<VoiceRecordingButton> createState() => _VoiceRecordingButtonState();
}

class _VoiceRecordingButtonState extends State<VoiceRecordingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap(VoiceRecordingState state) {
    if (state.isProcessing) return;

    if (!state.isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  void _startRecording() {
    _pulseController.repeat(reverse: true);
    context.read<VoiceRecordingBloc>().add(const StartVoiceRecordingEvent());
  }

  void _stopRecording() {
    _pulseController.stop();
    _pulseController.reset();
    context.read<VoiceRecordingBloc>().add(
      StopVoiceRecordingEvent(
        onComplete: (text) {
          widget.onTextRecognized?.call(text);
          widget.onRecordingComplete?.call();
        },
      ),
    );
  }

  void _handleLongPressStart(VoiceRecordingState state) {
    if (state.isProcessing) return;
    _scaleController.forward();
  }

  void _handleLongPressEnd(VoiceRecordingState state) {
    _scaleController.reverse();
  }

  void _handleError(String error, ThemeData theme) {
    _pulseController.stop();
    _pulseController.reset();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<VoiceRecordingBloc, VoiceRecordingState>(
      listener: (context, state) {
        if (state.error != null) {
          _handleError(state.error!, theme);
        }
      },
      child: BlocBuilder<VoiceRecordingBloc, VoiceRecordingState>(
        builder: (context, state) {
          return AnimatedMicrophoneButton(
            state: state,
            pulseAnimation: _pulseAnimation,
            scaleAnimation: _scaleAnimation,
            onTap: () => _handleTap(state),
            onLongPressStart: () => _handleLongPressStart(state),
            onLongPressEnd: () => _handleLongPressEnd(state),
          );
        },
      ),
    );
  }
} 