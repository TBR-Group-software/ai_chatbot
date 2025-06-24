import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_chat_bot/presentation/bloc/voice_recording/voice_recording_bloc.dart';
import 'package:ai_chat_bot/presentation/widgets/animated_microphone_button.dart';

/// A comprehensive voice recording button widget that manages the complete recording lifecycle.
///
/// This widget provides an intuitive interface for voice recording operations,
/// handling user interactions, animations, and integration with the recording
/// BLoC. It serves as the primary entry point for voice recording functionality
/// in the application.
///
/// The widget supports multiple interaction modes and provides visual feedback
/// through sophisticated animations:
/// * **Tap to Record**: Simple tap interaction for quick voice recording
/// * **Visual Feedback**: Animated microphone with pulsing effects during recording
/// * **State Management**: Seamless integration with [VoiceRecordingBloc]
/// * **Error Handling**: User-friendly error display with SnackBar notifications
/// * **Callback Support**: Flexible callback system for completion and text recognition
///
/// Key features:
/// * Animated microphone button with pulse and scale animations
/// * Automatic error handling with visual feedback
/// * Callback-based architecture for flexible integration
/// * BLoC pattern integration for reactive state management
/// * Accessibility support with proper gesture handling
///
/// Example usage:
/// ```dart
/// // Basic voice recording button
/// VoiceRecordingButton(
///   onRecordingComplete: () {
///     print('Recording completed');
///   },
///   onTextRecognized: (text) {
///     print('Recognized text: $text');
///     _handleRecognizedText(text);
///   },
/// )
///
/// // In a chat interface
/// FloatingActionButton.extended(
///   onPressed: null, // Disabled, using custom widget
///   label: VoiceRecordingButton(
///     onTextRecognized: (text) {
///       context.read<ChatBloc>().add(
///         SendMessageEvent(text),
///       );
///     },
///   ),
/// )
///
/// // With custom styling in a form
/// Container(
///   padding: const EdgeInsets.all(16),
///   child: VoiceRecordingButton(
///     onRecordingComplete: () => _showRecordingComplete(),
///     onTextRecognized: (text) => _controller.text = text,
///   ),
/// )
/// ```
///
/// Animation details:
/// * **Pulse Animation**: 800ms duration with ease-in-out curve during recording
/// * **Scale Animation**: 150ms duration for press feedback
/// * **Automatic Control**: Animations start/stop based on recording state
class VoiceRecordingButton extends StatefulWidget {

  /// Creates a voice recording button widget.
  ///
  /// Both callback parameters are optional, allowing flexible integration
  /// with different use cases. The widget will function properly without
  /// callbacks, but they enable custom handling of recording results.
  ///
  /// [onRecordingComplete] Optional callback for recording completion
  /// [onTextRecognized] Optional callback for text recognition results
  const VoiceRecordingButton({
    super.key,
    this.onRecordingComplete,
    this.onTextRecognized,
  });
  /// Called when the recording process is completed successfully.
  ///
  /// This callback is invoked after the recording has been stopped and
  /// processed, regardless of whether text recognition was successful.
  /// It provides a way to handle post-recording UI updates or navigation.
  ///
  /// The callback is executed after [onTextRecognized] if both are provided.
  final VoidCallback? onRecordingComplete;
  
  /// Called when speech-to-text recognition produces results.
  ///
  /// This callback receives the final recognized text from the voice
  /// recording session. The text parameter contains the complete
  /// transcription of the user's speech.
  ///
  /// The callback is executed before [onRecordingComplete] if both are provided.
  ///
  /// Example usage:
  /// ```dart
  /// VoiceRecordingButton(
  ///   onTextRecognized: (recognizedText) {
  ///     // Handle the recognized text
  ///     _messageController.text = recognizedText;
  ///     _sendMessage();
  ///   },
  /// )
  /// ```
  final void Function(String text)? onTextRecognized;

  @override
  State<VoiceRecordingButton> createState() => _VoiceRecordingButtonState();
}

/// Private state class for [VoiceRecordingButton] that manages animations and interactions.
///
/// This state class handles the complex animation lifecycle and user interaction
/// patterns required for an intuitive voice recording experience. It coordinates
/// multiple animation controllers and integrates with the BLoC pattern for
/// state management.
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

  /// Initializes the animation controllers and animations for the recording button.
  ///
  /// Sets up two primary animations:
  /// * **Pulse Animation**: Creates a pulsing effect during recording with 800ms duration
  /// * **Scale Animation**: Provides tactile feedback on press with 150ms duration
  ///
  /// Both animations use appropriate curves for natural feeling interactions:
  /// * Pulse uses ease-in-out for smooth breathing effect
  /// * Scale uses ease-in-out for responsive press feedback
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
      begin: 1,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ),);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Handles tap gestures on the recording button.
  ///
  /// Determines the appropriate action based on the current recording state:
  /// * If not recording: starts a new recording session
  /// * If recording: stops the current recording session
  /// * If processing: ignores the tap to prevent conflicts
  ///
  /// The method coordinates with the animation system to provide visual
  /// feedback that matches the recording state transitions.
  ///
  /// [state] The current voice recording state from the BLoC
  void _handleTap(VoiceRecordingState state) {
    if (state.isProcessing) {
      return;
    }

    if (!state.isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  /// Initiates a new voice recording session.
  ///
  /// Starts the pulse animation to provide visual feedback and dispatches
  /// the start recording event to the BLoC. The pulse animation continues
  /// until the recording is stopped or an error occurs.
  void _startRecording() {
    _pulseController.repeat(reverse: true);
    context.read<VoiceRecordingBloc>().add(const StartVoiceRecordingEvent());
  }

  /// Stops the current recording session and processes the results.
  ///
  /// Stops the pulse animation and dispatches the stop recording event
  /// to the BLoC with completion callbacks. The callbacks are invoked
  /// when the recording processing is complete.
  ///
  /// The method ensures proper cleanup of animations and state before
  /// invoking the widget's callback functions.
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

  /// Handles the start of long press gestures for tactile feedback.
  ///
  /// Initiates the scale animation to provide visual feedback when the
  /// user begins a long press. This creates a responsive feel even though
  /// the primary interaction is tap-based.
  ///
  /// [state] The current voice recording state from the BLoC
  void _handleLongPressStart(VoiceRecordingState state) {
    if (state.isProcessing) {
      return;
    }
    _scaleController.forward();
  }

  /// Handles the end of long press gestures.
  ///
  /// Reverses the scale animation to return the button to its normal
  /// size, completing the tactile feedback cycle.
  ///
  /// [state] The current voice recording state from the BLoC
  void _handleLongPressEnd(VoiceRecordingState state) {
    _scaleController.reverse();
  }

  /// Handles error states by stopping animations and showing user feedback.
  ///
  /// Ensures proper cleanup of the animation state and displays a
  /// user-friendly error message using a SnackBar. The error handling
  /// is designed to be non-intrusive while providing clear feedback.
  ///
  /// [error] The error message to display to the user
  /// [theme] The current theme for consistent styling
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
