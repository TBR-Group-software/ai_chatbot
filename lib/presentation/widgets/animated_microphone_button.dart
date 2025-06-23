import 'package:flutter/material.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/presentation/bloc/voice_recording/voice_recording_bloc.dart';

/// Enumeration defining the visual states of the recording button.
///
/// This enum provides a clear abstraction for the different visual
/// states the microphone button can display, enabling clean switch
/// statements and consistent state management.
///
/// States:
/// * [processing] - Button is in a processing/loading state
/// * [recording] - Button is actively recording audio
/// * [idle] - Button is ready for user interaction
enum RecordingButtonState {
  /// The button is processing a request (initializing, stopping, etc.)
  processing,
  
  /// The button is actively recording audio input
  recording,
  
  /// The button is idle and ready for user interaction
  idle,
}

/// A sophisticated animated microphone button that provides rich visual feedback for voice recording states.
///
/// This widget serves as the visual representation component of the voice recording
/// system, handling complex animations, theming, and state-based styling. It
/// transforms recording states into intuitive visual cues that guide user interaction.
///
/// Example usage:
/// ```dart
/// // Basic animated microphone button
/// AnimatedMicrophoneButton(
///   state: voiceRecordingState,
///   pulseAnimation: _pulseAnimation,
///   scaleAnimation: _scaleAnimation,
///   onTap: () => _handleRecordingTap(),
///   onLongPressStart: () => _showFeedback(),
///   onLongPressEnd: () => _hideFeedback(),
/// )
///
/// // With custom animation controllers
/// AnimationController _pulseController = AnimationController(
///   duration: const Duration(milliseconds: 800),
///   vsync: this,
/// );
/// 
/// Animation<double> _pulseAnimation = Tween<double>(
///   begin: 1.0,
///   end: 1.3,
/// ).animate(_pulseController);
///
/// AnimatedMicrophoneButton(
///   state: state,
///   pulseAnimation: _pulseAnimation,
///   scaleAnimation: _scaleAnimation,
///   onTap: _toggleRecording,
///   onLongPressStart: _startFeedback,
///   onLongPressEnd: _endFeedback,
/// )
/// ```
///
/// Performance considerations:
/// * Uses [AnimatedBuilder] for efficient animation rebuilds
/// * Minimizes widget tree rebuilds through strategic state management
/// * Optimized shadow calculations for smooth animation performance
/// * Efficient color and style calculations with caching
class AnimatedMicrophoneButton extends StatelessWidget {

  /// Creates an animated microphone button widget.
  ///
  /// All parameters are required to ensure proper functionality and
  /// animation behavior. The widget relies on external animation
  /// controllers and state management for its operation.
  ///
  /// [state] Current voice recording state for visual determination
  /// [pulseAnimation] Animation for pulsing effect during recording
  /// [scaleAnimation] Animation for press feedback
  /// [onTap] Callback for primary button interaction
  /// [onLongPressStart] Callback for long press start
  /// [onLongPressEnd] Callback for long press end
  const AnimatedMicrophoneButton({
    super.key,
    required this.state,
    required this.pulseAnimation,
    required this.scaleAnimation,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });
  /// The current voice recording state from the BLoC.
  ///
  /// This state object contains all the information needed to determine
  /// the button's visual appearance and behavior. The widget reacts to
  /// changes in this state to update its visual representation.
  final VoiceRecordingState state;
  
  /// Animation that controls the pulsing effect during recording.
  ///
  /// This animation should typically animate from 1.0 to 1.3 and repeat
  /// with reverse to create a breathing/pulsing effect. It's active only
  /// during the recording state and affects both the button scale and
  /// shadow radius.
  ///
  /// Recommended configuration:
  /// ```dart
  /// Animation<double> pulseAnimation = Tween<double>(
  ///   begin: 1.0,
  ///   end: 1.3,
  /// ).animate(CurvedAnimation(
  ///   parent: controller,
  ///   curve: Curves.easeInOut,
  /// ));
  /// ```
  final Animation<double> pulseAnimation;
  
  /// Animation that provides tactile feedback during press interactions.
  ///
  /// This animation should scale the button slightly down (to ~0.95) when
  /// pressed and return to normal when released. It provides immediate
  /// visual feedback for user interactions.
  ///
  /// Recommended configuration:
  /// ```dart
  /// Animation<double> scaleAnimation = Tween<double>(
  ///   begin: 1.0,
  ///   end: 0.95,
  /// ).animate(CurvedAnimation(
  ///   parent: controller,
  ///   curve: Curves.easeInOut,
  /// ));
  /// ```
  final Animation<double> scaleAnimation;
  
  /// Callback invoked when the button is tapped.
  ///
  /// This callback should handle the primary button interaction, typically
  /// toggling between recording and idle states. The callback should check
  /// the current state and take appropriate action.
  final VoidCallback onTap;
  
  /// Callback invoked when a long press gesture begins.
  ///
  /// This callback is used to provide additional tactile feedback and can
  /// be used to start auxiliary animations or show additional UI elements.
  /// It's called at the start of a long press gesture.
  final VoidCallback onLongPressStart;
  
  /// Callback invoked when a long press gesture ends.
  ///
  /// This callback complements [onLongPressStart] and is used to clean up
  /// any auxiliary animations or UI elements that were activated during
  /// the long press. It's called when the long press gesture is released.
  final VoidCallback onLongPressEnd;

  /// Determines the current visual state of the button based on recording state.
  ///
  /// This computed property maps the complex [VoiceRecordingState] to a
  /// simplified [RecordingButtonState] enum that's easier to use in
  /// switch statements for visual styling.
  ///
  /// State mapping:
  /// * Processing states (initializing, stopping, cancelling) → [RecordingButtonState.processing]
  /// * Active recording → [RecordingButtonState.recording]
  /// * All other states → [RecordingButtonState.idle]
  RecordingButtonState get _buttonState {
    if (state.isProcessing) {
      return RecordingButtonState.processing;
    }
    if (state.isRecording) {
      return RecordingButtonState.recording;
    }
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

  /// Determines the background color based on the current button state.
  ///
  /// This method implements the color scheme for different recording states,
  /// providing visual cues about the button's current functionality. The
  /// colors are sourced from the app's theme system for consistency.
  ///
  /// Color mapping:
  /// * **Processing**: Dimmed surface color to indicate unavailability
  /// * **Recording**: Error color (typically red) to indicate active recording
  /// * **Idle**: Primary color for normal interactive state
  ///
  /// [theme] The current Flutter theme data
  /// [customColors] The app's custom color extension
  ///
  /// Returns the appropriate [Color] for the current state.
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

  /// Generates appropriate box shadows based on recording state and animations.
  ///
  /// This method creates dynamic shadow effects that enhance the visual
  /// feedback during different states. The shadows are animated during
  /// recording to create a pulsing effect synchronized with the button scale.
  ///
  /// Shadow behaviors:
  /// * **Recording**: Animated shadow with pulsing radius and spread
  /// * **Non-recording**: Static shadow with consistent offset and blur
  ///
  /// The shadow colors are themed appropriately:
  /// * Recording shadow uses microphone-specific color
  /// * Button shadow uses general button shadow color
  ///
  /// [customColors] The app's custom color extension for shadow colors
  ///
  /// Returns a list of [BoxShadow] objects for the container decoration.
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

  /// Selects the appropriate icon based on the current button state.
  ///
  /// This method provides intuitive iconography that clearly communicates
  /// the button's current function to users. The icons are from Material
  /// Design's standard icon set for consistency.
  ///
  /// Icon mapping:
  /// * **Processing**: Hourglass icon to indicate waiting/loading state
  /// * **Recording**: Stop icon to indicate recording can be stopped
  /// * **Idle**: Microphone icon to indicate recording can be started
  ///
  /// Returns the appropriate [IconData] for the current state.
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

  /// Determines the icon color based on the current button state and theme.
  ///
  /// This method ensures proper contrast and accessibility by selecting
  /// appropriate icon colors that work well with the background colors.
  /// All colors respect the app's theme system for consistency.
  ///
  /// Color mapping:
  /// * **Processing**: Standard on-surface color for neutral state
  /// * **Recording**: White for high contrast against error background
  /// * **Idle**: On-primary color for proper contrast against primary background
  ///
  /// [theme] The current Flutter theme data
  /// [customColors] The app's custom color extension
  ///
  /// Returns the appropriate [Color] for the icon.
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
