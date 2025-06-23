import 'package:flutter/material.dart';
import 'package:ai_chat_bot/core/theme/app_theme.dart';
import 'package:ai_chat_bot/presentation/bloc/voice_recording/voice_recording_bloc.dart';
import 'package:ai_chat_bot/presentation/widgets/audio_waveform_painter.dart';

/// A sophisticated real-time audio waveform visualization widget for voice recording interfaces.
///
/// This widget provides an intuitive visual representation of audio input levels
/// during voice recording sessions. It displays animated waveforms that respond
/// to real-time sound levels, creating an engaging and informative user experience
/// that helps users understand their recording status and audio input quality.
///
/// The visualization features advanced capabilities:
/// * **Real-time Responsiveness**: Waveform amplitude changes based on actual audio levels
/// * **State-aware Display**: Different visual modes for listening, recording, and idle states
/// * **Smooth Animations**: Continuous animation controller for fluid waveform movement
/// * **Theme Integration**: Fully integrated with app's custom color scheme
/// * **Recording Feedback**: Visual indicators that confirm recording is active
/// * **Professional Appearance**: Modern rounded design suitable for production apps
///
/// Technical features:
/// * **Custom Painting**: Uses [AudioWaveformPainter] for optimized waveform rendering
/// * **Animation Integration**: Seamlessly works with external animation controllers
/// * **State Management**: Reactive to [VoiceRecordingState] changes
/// * **Performance Optimized**: Efficient rendering with minimal CPU impact
/// * **Responsive Design**: Adapts to different container sizes and orientations
///
/// Visual design:
/// * **Rounded Container**: 60px height with 30px border radius for modern appearance
/// * **Dynamic Colors**: Waveform colors adapt based on recording state
/// * **Amplitude Mapping**: Sound levels directly control waveform visual intensity
/// * **Smooth Transitions**: All state changes are visually smooth and intuitive
///
/// Example usage:
/// ```dart
/// // Basic waveform visualization
/// class RecordingInterface extends StatefulWidget {
///   @override
///   _RecordingInterfaceState createState() => _RecordingInterfaceState();
/// }
///
/// class _RecordingInterfaceState extends State<RecordingInterface>
///     with TickerProviderStateMixin {
///   late AnimationController _waveController;
///
///   @override
///   void initState() {
///     super.initState();
///     _waveController = AnimationController(
///       duration: const Duration(seconds: 2),
///       vsync: this,
///     )..repeat();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     final theme = Theme.of(context);
///     final customColors = theme.extension<CustomColors>()!;
///
///     return BlocBuilder<VoiceRecordingBloc, VoiceRecordingState>(
///       builder: (context, state) {
///         return WaveVisualization(
///           state: state,
///           waveController: _waveController,
///           theme: theme,
///           customColors: customColors,
///         );
///       },
///     );
///   }
/// }
///
/// // In a recording modal
/// Container(
///   padding: const EdgeInsets.all(16),
///   child: Column(
///     children: [
///       const Text('Recording...'),
///       const SizedBox(height: 16),
///       WaveVisualization(
///         state: recordingState,
///         waveController: animationController,
///         theme: Theme.of(context),
///         customColors: customColors,
///       ),
///       const SizedBox(height: 16),
///       RecordingControls(),
///     ],
///   ),
/// )
/// ```
///
/// Animation controller setup:
/// ```dart
/// // Recommended animation controller configuration
/// AnimationController waveController = AnimationController(
///   duration: const Duration(seconds: 2),
///   vsync: this,
/// );
///
/// // Start animation when recording begins
/// if (state.isRecording) {
///   waveController.repeat();
/// } else {
///   waveController.stop();
/// }
/// ```
///
/// Performance considerations:
/// * Uses efficient custom painting for smooth 60fps animations
/// * Minimizes rebuilds through strategic use of AnimatedBuilder
/// * Optimized waveform calculations for real-time responsiveness
/// * Memory-efficient color and style management
class WaveVisualization extends StatelessWidget {

  /// Creates a wave visualization widget.
  ///
  /// All parameters are required for proper functionality. The widget
  /// depends on external state and animation management for its operation.
  ///
  /// [state] Current voice recording state for visual adaptation
  /// [waveController] Animation controller for waveform movement
  /// [theme] Flutter theme data for consistent styling
  /// [customColors] Custom color scheme for app-specific theming
  const WaveVisualization({
    super.key,
    required this.state,
    required this.waveController,
    required this.theme,
    required this.customColors,
  });
  /// The current voice recording state from the BLoC.
  ///
  /// This state contains the real-time audio information needed for
  /// waveform visualization, including:
  /// * [soundLevel] - Current audio input amplitude (0.0 to 1.0)
  /// * [isListening] - Whether the system is actively listening
  /// * [isRecording] - Whether recording is in progress
  ///
  /// The waveform visual appearance adapts based on these state values
  /// to provide immediate feedback about recording status.
  final VoiceRecordingState state;
  
  /// Animation controller that drives the waveform movement.
  ///
  /// This controller should typically be configured to repeat indefinitely
  /// for continuous waveform animation. The animation value is used to
  /// create the flowing wave effect across the visualization.
  ///
  /// Recommended configuration:
  /// ```dart
  /// AnimationController(
  ///   duration: const Duration(seconds: 2),
  ///   vsync: this,
  /// )..repeat();
  /// ```
  ///
  /// The controller should be started when recording begins and stopped
  /// when recording ends for optimal performance.
  final AnimationController waveController;
  
  /// The current Flutter theme data.
  ///
  /// Used for consistent styling and color scheme integration. The
  /// waveform colors and appearance adapt to the current theme to
  /// maintain visual consistency with the rest of the application.
  final ThemeData theme;
  
  /// Custom color extension for app-specific theming.
  ///
  /// Provides access to specialized colors used in the waveform
  /// visualization:
  /// * [iconBackground] - Background color for the waveform container
  /// * [waveformColor] - Primary color for waveform rendering
  ///
  /// These colors ensure the waveform integrates seamlessly with the
  /// app's visual design system.
  final CustomColors customColors;

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
